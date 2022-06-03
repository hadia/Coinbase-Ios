//
//  CoinbaseApp.swift
//  Coinbase
//
//  Created by hadia on 24/05/2022.
//

import SwiftUI

@available(iOS 14.0, *)
@main
struct CoinbaseApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
