//
//  CoinbaseAPIEndpoint.swift
//  Coinbase
//
//  Created by hadia on 28/05/2022.
//

import Foundation
/// BaseUrl API Endpoint
private let baseURL = URL(string: "https://api.coinbase.com/v2/")

enum APIEndpoint: Endpoint {
    var url: URL {
        return URL(string: self.path, relativeTo: baseURL)!
    }
    
    var path: String {
        switch self {
        case .userAccounts(let limit): return "accounts?limit=\(limit)"
        case .userAuthInformation: return "user/auth"
        case .exchangeRates(let currency): return "exchange-rates?currency=\(currency)"
        case .activePaymentMethods: return "payment-methods"
        case .placeBuyOrder(let accountId): return "accounts/\(accountId)/buys"
        case .commitBuyOrder(let accountId,let orderID): return "accounts/\(accountId)/buys/\(orderID)/commit"
        case .sendCoinsToWallet(let accountId): return "accounts/\(accountId)/transactions"
        case .getBaseIdForUSDModel(let baseCurrency): return "/assets/prices?base=\(baseCurrency)&filter=holdable&resolution=latest"
        case .swapTrade: return "trades"
        case .swapTradeCommit(let tradeId): return "trades/\(tradeId)/commit"
        case .accountAddress(let accountId): return "accounts/\(accountId)/addresses"
        case .createAccountAddress(let accountId): return "accounts/\(accountId)/addresses"
        }
    }
    
    case userAccounts(Int)
    case userAuthInformation
    case exchangeRates(String)
    case activePaymentMethods
    case placeBuyOrder(String)
    case commitBuyOrder(String,String)
    case sendCoinsToWallet(String)
    case getBaseIdForUSDModel(String)
    case swapTrade
    case swapTradeCommit(String)
    case accountAddress(String)
    case createAccountAddress(String)
}
