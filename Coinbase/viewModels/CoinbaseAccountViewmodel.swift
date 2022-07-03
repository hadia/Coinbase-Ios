//
//  CoinbaseAccountViewmodel.swift
//  Coinbase
//
//  Created by hadia on 31/05/2022.
//

import Foundation
import Combine
import Resolver
import AuthenticationServices

class CoinbaseAccountViewmodel: NSObject,ObservableObject {
    @Injected
    private var getUserCoinbaseAccounts: GetUserCoinbaseAccounts
    
    @Injected
    private var getUserCoinbaseToken: GetUserCoinbaseToken
    
    @Published
    var accounts: [CoinbaseUserAccountData] = []
    
    private var cancelables = [AnyCancellable]()
    
    @Published
    var dashAccount: CoinbaseUserAccountData?
    
    @Published
    var isConnected: Bool = false
    
    func loadUserCoinbaseAccounts() {
        getUserCoinbaseAccounts.invoke()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] response in
                self?.dashAccount = response
            })
            .store(in: &cancelables)
    }
    func signOutTapped(){
        getUserCoinbaseToken.signOut()
        isConnected = false
        signInTapped()
    }
    
    func signInTapped() {
        if (getUserCoinbaseToken.isUserLoginedIn()){
            isConnected = true
            loadUserCoinbaseAccounts()
        } else{
            
            let path =  APIEndpoint.signIn.path
            
            
            var queryItems = [
                URLQueryItem(name: "redirect_uri", value: NetworkRequest.redirect_uri),
                URLQueryItem(name: "response_type", value: NetworkRequest.response_type),
                URLQueryItem(name: "scope", value: NetworkRequest.scope),
                URLQueryItem(name: "meta[\("send_limit_amount")]", value: "\(NetworkRequest.send_limit_amount)"),
                URLQueryItem(name: "meta[\("send_limit_currency")]", value: NetworkRequest.send_limit_currency),
                URLQueryItem(name: "meta[\("send_limit_period")]", value: NetworkRequest.send_limit_period),
                URLQueryItem(name: "account", value: NetworkRequest.account)
            ]
            
            if let  clientID = NetworkRequest.clientID as?String{
                queryItems.append(   URLQueryItem(name: "client_id", value: clientID))
            }
            
            
            
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "coinbase.com"
            urlComponents.path = path
            urlComponents.queryItems =  queryItems
            //
            
            guard let signInURL =  urlComponents.url
            else {
                print("Could not create the sign in URL .")
                return
            }
            
            let callbackURLScheme = NetworkRequest.callbackURLScheme
            print(signInURL)
            
            let authenticationSession = ASWebAuthenticationSession(
                url: signInURL,
                callbackURLScheme: callbackURLScheme ) { callbackURL, error in
                    // 1
                    guard
                        error == nil,
                        let callbackURL = callbackURL,
                        // 2
                        let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems,
                        // 3
                        let code = queryItems.first(where: { $0.name == "code" })?.value
                            // 4
                    else {
                        // 5
                        print("An error occurred when attempting to sign in.")
                        return
                    }
                    self.loadUserCoinbaseTokens(code: code)
                    
                }
            
            authenticationSession.presentationContextProvider = self
            authenticationSession.prefersEphemeralWebBrowserSession = true
            
            if !authenticationSession.start() {
                print("Failed to start ASWebAuthenticationSession")
            }
        }
    }
    
    func loadUserCoinbaseTokens(code: String) {
        getUserCoinbaseToken.invoke(code: code)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] response in
                if( response?.accessToken?.isEmpty==false){
                    self?.isConnected = true
                    self?.loadUserCoinbaseAccounts()
                }
            })
            .store(in: &cancelables)
        
    }
    
}

extension CoinbaseAccountViewmodel: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession)
    -> ASPresentationAnchor {
        let window = UIApplication.shared.connectedScenes
        // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
        // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
        // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
        // Finally, keep only the key window
            .first(where: \.isKeyWindow)
        
        return window ?? ASPresentationAnchor()
    }
    
}
