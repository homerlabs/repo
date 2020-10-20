//
//  ContentView.swift
//  HLCrypto
//
//  Created by Matthew Homer on 2/25/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import SwiftUI

struct HLCryptoView: View {

    @ObservedObject var cryptoViewModel = HLCryptoViewModel()
 //   let textFieldBackgroundColor = Color(red: 0.9, green: 0.9, blue: 0.9)
    let windowBackgroundColor = Color(red: 0.85, green: 0.89, blue: 0.91)
 //   let appWidth: CGFloat = 620
//    let appHeight: CGFloat = 346

    var body: some View {
        VStack {
            TopSectionView(cryptoViewModel: cryptoViewModel)
            MiddleSectionView(cryptoViewModel: cryptoViewModel)
            BottomSectionView(cryptoViewModel: cryptoViewModel)
        }
        .padding()
        .background(windowBackgroundColor)
        .onAppear() {
            self.cryptoViewModel.setupRSA()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HLCryptoView()
    }
}
