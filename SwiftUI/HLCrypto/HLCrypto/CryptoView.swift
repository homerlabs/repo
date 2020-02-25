//
//  ContentView.swift
//  HLCrypto
//
//  Created by Matthew Homer on 2/25/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import SwiftUI

struct CryptoView: View {

    @ObservedObject var cryptoViewModel = HLCryptoViewModel()
    let HLSavePanelTitle = "HLCrypto Save Panel"

    var body: some View {
        VStack {
        
            //  set Plaintext path
            HStack {
                Button(action: {
                    print("PlainTextPath")
                    let path = "PlainText.txt"
                    
                    //  will come back nil if user cancels
                    if let url = path.getSaveFilePath(title: self.HLSavePanelTitle, message: "Set PlainText File Path") {
                        self.cryptoViewModel.plainTextPath = url.path
                    }
                }) {
                    Text("    PlainText   ")
                }
                
                Text(cryptoViewModel.plainTextPath)
            //        .frame(maxWidth: .infinity, maxHeight: .infinity)
                Spacer()
            }
            
            //  set Ciphertext path
            HStack {
                Button(action: {
                    print("CipherTextPath")
                    let path = "CipherText.txt"
                    
                    //  will come back nil if user cancels
                    if let url = path.getSaveFilePath(title: self.HLSavePanelTitle, message: "Set CipherText File Path") {
                        self.cryptoViewModel.cipherTextPath = url.path
                    }
}) {
                    Text("  CipherText  ")
                }
                
                Text(cryptoViewModel.cipherTextPath)
                Spacer()
            }
            
            //  set DeCiphertext path
            HStack {
                Button(action: {
                    print("DeCipherTextPath")
                    let path = "DeCipherText.txt"
                    
                    //  will come back nil if user cancels
                    if let url = path.getSaveFilePath(title: self.HLSavePanelTitle, message: "Set DeCipher Text File Path") {
                        self.cryptoViewModel.decipherTextPath = url.path
                    }
                }) {
                    Text("DeCipherText")
                }
                
                Text(cryptoViewModel.decipherTextPath)
                Spacer()
            }
            
            Form {
            //  set P, Q
              HStack {
                  Text("P:")
                  TextField(cryptoViewModel.pString, text: $cryptoViewModel.pString)
                  Spacer()
                  Text("Q:")
                  TextField(cryptoViewModel.qString, text: $cryptoViewModel.qString)
                  Spacer()
                  Text("P*Q: \(cryptoViewModel.pTimesQ())")
                  Spacer()
                  Text("(P-1)(Q-1)): \(cryptoViewModel.pMinus1QMinus1())")
            //      let value = (Int(cryptoViewModel.qString) - 1) * (Int(cryptoViewModel.qString) - 1)
                  Spacer()
              }

              //  set chosenKey
              HStack {
                  Text("Chosen Key:")
                  TextField(cryptoViewModel.chosenKeyString, text: $cryptoViewModel.chosenKeyString)
                  Spacer()
                  Text("Calculated Key:")
                  Text("42")
            //      let value = (Int(cryptoViewModel.qString) - 1) * (Int(cryptoViewModel.qString) - 1)
                  Spacer()
              }

              //  Encode and Decode Buttons
              HStack {
                  Spacer()
                  Button(action: {
                      print("Encode")
                  }) {
                      Text("Encode")
                  }
                  Spacer()
                  Button(action: {
                      print("Decode")
                  }) {
                      Text("Decode")
                  }
                  Spacer()
              }
            }

            Spacer()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CryptoView()
    }
}
