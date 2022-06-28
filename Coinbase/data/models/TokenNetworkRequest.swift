//
//  TokenNetworkRequest.swift
//  Coinbase
//
//  Created by hadia on 20/06/2022.
//

import Foundation

struct NetworkRequest {
// MARK: Private Constants
static let callbackURLScheme = "authhub"
static let clientSecret="9337e6c28cd78fe76f4283e717cea82456a64bf377993b3947ddc01e9417d193"
static let grant_type = "authorization_code"
static let redirect_uri = "authhub://oauth-callback"
static let clientID = "874b96e780c481a2d72f295ab25f28a0c3948b7eadfd16927d771fc500aa8ee1"
static let response_type = "code"
static let scope = "wallet:accounts:read,wallet:user:read,wallet:payment-methods:read,wallet:buys:read,wallet:buys:create,wallet:transactions:transfer,wallet:transactions:request,wallet:transactions:read,wallet:transactions:send"
static let send_limit_currency = "USD"
static let send_limit_amount = 1
static let send_limit_period = "month"
static let account = "all"
    // MARK: Private Constants
    private static let accessTokenKey = "accessToken"
    private static let refreshTokenKey = "refreshToken"
    private static let usernameKey = "username"
    
    // MARK: Properties
    static var accessToken: String? {
      get {
        UserDefaults.standard.string(forKey: accessTokenKey)
      }
      set {
        UserDefaults.standard.setValue(newValue, forKey: accessTokenKey)
      }
    }

    static var refreshToken: String? {
      get {
        UserDefaults.standard.string(forKey: refreshTokenKey)
      }
      set {
        UserDefaults.standard.setValue(newValue, forKey: refreshTokenKey)
      }
    }

    static var username: String? {
      get {
        UserDefaults.standard.string(forKey: usernameKey)
      }
      set {
        UserDefaults.standard.setValue(newValue, forKey: usernameKey)
      }
    }
}
