//
//  CoinbaseAccountViewmodel.swift
//  Coinbase
//
//  Created by hadia on 31/05/2022.
//

import Foundation
import Combine
import Resolver

class CoinbaseAccountViewmodel: ObservableObject {
    @Injected
    private var getUserCoinbaseAccounts: GetUserCoinbaseAccounts
    @Published
    var accounts: [CoinbaseUserAccountData] = []
    private var cancelables = [AnyCancellable]()
    
    func loadUserCoinbaseAccounts() {
        getUserCoinbaseAccounts.invoke()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] response in
                self?.accounts = response.data
            })
            .store(in: &cancelables)
    }
}
