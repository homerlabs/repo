//
//  TopSectionView.swift
//  HLCrypto
//
//  Created by Matthew Homer on 10/19/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import SwiftUI

struct TopSectionView: View {
    @ObservedObject var cryptoViewModel: HLCryptoViewModel
    let textFieldBackgroundColor = Color(red: 0.9, green: 0.9, blue: 0.9)
    let HLSavePanelTitle = "HLCrypto Save Panel"
    let HLOpenPanelTitle = "HLCrypto Open Panel"

    var body: some View {
        VStack {
            //**********  set Plaintext path
            HStack {
                Button(action: {
                    print("PlainTextPath")
                    let path = "PlainText.txt"
                    self.cryptoViewModel.plainTextURL = path.getOpenFilePath(title: self.HLOpenPanelTitle)
                }) {
                    Text("    PlainText    ")
                }
                
                if cryptoViewModel.plainTextURL != nil {
                    Text(cryptoViewModel.plainTextURL!.path)
                    .background(textFieldBackgroundColor)
                } else {
                    Text("Plaintext Path not set")
                    .background(textFieldBackgroundColor)
                }
                Spacer()
            }
           
            //**********  set Ciphertext path
            HStack {
                Button(action: {
                    print("CipherTextPath")
                    let path = "CipherText.txt"
                    self.cryptoViewModel.cipherTextURL = path.getSaveFilePath(title: self.HLSavePanelTitle, message: "Set CipherText File Path")
                }) {
                    Text("  CipherText   ")
                }
                
                if cryptoViewModel.cipherTextURL != nil {
                    Text(cryptoViewModel.cipherTextURL!.path)
                    .background(textFieldBackgroundColor)
                } else {
                    Text("Ciphertext Path not set")
                    .background(textFieldBackgroundColor)
                }
                Spacer()
            }
            
            //**********  set DeCiphertext path
            HStack {
                Button(action: {
                    print("DeCipherTextPath")
                    let path = "DeCipherText.txt"
                    self.cryptoViewModel.decipherTextURL = path.getSaveFilePath(title: self.HLSavePanelTitle, message: "Set DeCipherText File Path")
                }) {
                    Text("DeCipherText")
                }
                
                if cryptoViewModel.decipherTextURL != nil {
                    Text(cryptoViewModel.decipherTextURL!.path)
                    .background(textFieldBackgroundColor)
                } else {
                    Text("DeCiphertext Path not set")
                    .background(textFieldBackgroundColor)
                }
                Spacer()
            }
        }
    }
}

struct TopSectionView_Previews: PreviewProvider {
    static var previews: some View {
        TopSectionView(cryptoViewModel: HLCryptoViewModel())
    }
}
