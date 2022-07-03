//
//  ContentView.swift
//  Coinbase
//
//  Created by hadia on 24/05/2022.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject
    private var viewModel = CoinbaseAccountViewmodel()
    
    var body: some View {
        NavigationView {
            ZStack  {
                Color.white
                    .ignoresSafeArea()
                
                // NavigationView Background
                VStack {
                    Color.screenBackgroundColor
                    Spacer()
                }
                
                VStack(alignment: .center) {
                    
                    let dashBalance = viewModel.dashAccount?.balance.amount ?? ""
                    Color.screenBackgroundColor.frame(height: 20)
                    
                    if (dashBalance != ""){
                        Text("Dash balance on Coinbase")
                            .font(Font.custom("MontserratRegular", size: 12))
                        HStack{
                            Image("dashCurrency").padding(14)
                            Text(dashBalance)
                                .padding(.vertical, 5)
                                .font(Font.custom("MontserratMedium", size: 28))
                            
                        }
                    }
                    
                    
                    VStack(alignment: .center, spacing: 0){
                        
                        NavigationLink(destination: BuyCoinbaseView())
                        {                        CoinbaseServiceItem(imageName: "buyCoinbase",title: "Buy Dash",subTitle: "Receive directly into Dash Wallet.",showDivider: true)
                        }.buttonStyle(PlainButtonStyle())
                        
                        CoinbaseServiceItem(imageName: "sellDash",title: "Sell Dash",subTitle: "Receive directly into Coinbase.",showDivider: true)
                        CoinbaseServiceItem(imageName: "convertCrypto",title: "Convert Crypto",subTitle: "Between Dash Wallet and Coinbase.",showDivider: true)
                        CoinbaseServiceItem(imageName: "transferCoinbase",title: "Transfer Dash",subTitle: "Between Dash Wallet and Coinbase.")
                    }
                    .padding(.vertical, 5)
                    .background(Color.white.ignoresSafeArea())
                    .cornerRadius(10)
                    
                    
                    VStack(alignment: .center){
                        CoinbaseServiceItem(imageName: "logout",title: "Disconnect Coinbase Account")
                            .padding(.vertical, 5)
                            .background(Color.white.ignoresSafeArea())
                            .cornerRadius(10)
                    }.onTapGesture(perform: {
                        viewModel.signOutTapped()
                    })
                    
                }  .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
                    .padding(.horizontal, 15)
            }
            .onAppear(perform: {
                viewModel.signInTapped()
            })
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(alignment: .center ) {
                        let isConnected = viewModel.isConnected
                        Image( "Coinbase")
                        
                        VStack(spacing: 0 ) {
                            Text(LocalizedStringKey("Coinbase")).font(Font.custom("MontserratSemiBold", size: 16))
                            
                            HStack(spacing:4) {
                                if(isConnected){
                                    Image("Connected")
                                    Text( "Connected").font(Font.custom("MontserratRegular", size: 10))
                                }else{
                                    Image("Disconnected")
                                    Text("Disconnected").font(Font.custom("MontserratRegular", size: 10))
                                }
                                
                            }
                            
                        }
                    }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                }
            }
            
        }
    }
}


struct Previews_ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
