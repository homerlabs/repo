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
    @State var zeroPrimePMessage = false
    @State var zeroPrimeQMessage = false
    let HLSavePanelTitle = "HLCrypto Save Panel"
    let HLOpenPanelTitle = "HLCrypto Open Panel"
    let HLErrorInvalidDataTitle = "Data in TextField is not valid"
    let HLTextFieldWidth: CGFloat = 110

    var body: some View {
        VStack {
            Form {
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
                    } else {
                        Text("Plaintext Path not set")
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
                    } else {
                        Text("Ciphertext Path not set")
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
                    } else {
                        Text("DeCiphertext Path not set")
                    }
                    Spacer()
                }
            }
            
            VStack {
                //**********  Character Set, Chunk Size, and Character Set Size
                HStack {
                    Text("Character Set:")
                    Spacer()
                    Text("Chunk Size:")
                    Text(cryptoViewModel.chunkSize)
                    Spacer()
                    Text("Character Set Size:")
                    Text(cryptoViewModel.characterSetCountString)
                }
                
                TextField(cryptoViewModel.characterSet, text: $cryptoViewModel.characterSet)
                .lineLimit(2)
            }
             .padding(.vertical)
             
            Form {
              //**********  set P, Q
              HStack {
                  Text("P: ")
                  TextField(String(cryptoViewModel.primeP), value: $cryptoViewModel.primeP, formatter: NumberFormatter(), onCommit: {
                        if self.cryptoViewModel.primeP != 0 {
                            self.cryptoViewModel.setupRSA()
                        } else {
                            self.zeroPrimePMessage = true
                        }
                  })
                    .frame(width: HLTextFieldWidth)
                  Spacer()
                  
                  Text("Q: ")
                  TextField(String(cryptoViewModel.primeQ), value: $cryptoViewModel.primeQ, formatter: NumberFormatter(), onCommit: {
                        if self.cryptoViewModel.primeQ != 0 {
                            self.cryptoViewModel.setupRSA()
                        } else {
                            self.zeroPrimeQMessage = true
                        }
                  })
                    .frame(width: HLTextFieldWidth)
                  Spacer()
                  
                  Text("P*Q: \(cryptoViewModel.pqString)")
                  Spacer()
                  Text("(P-1)(Q-1): \(cryptoViewModel.gammaString)")
              }
              .alert(isPresented: $zeroPrimePMessage) {
                    Alert(title: Text(HLErrorInvalidDataTitle), message: Text("'P' value must be a non-zero integer"))}
              .alert(isPresented: $zeroPrimeQMessage) {
                    Alert(title: Text(HLErrorInvalidDataTitle), message: Text("'Q' value must be a non-zero integer"))}

              //**********  set chosenKey
              HStack {
                  Text("Chosen Key: ")
                  TextField(cryptoViewModel.chosenKeyString, text: $cryptoViewModel.chosenKeyString)
                    .frame(width: HLTextFieldWidth)
                  
       //           Spacer()
                  Text("Calculated Key:  " + cryptoViewModel.calculatedKeyString)
                  .padding(.horizontal)
                  Spacer()
              }
            .padding(.bottom)
        }

              //  Encode and Decode Buttons
              VStack {
                  Button(action: {
                      self.cryptoViewModel.encode()
                  }) {
                      Text("Encode")
                  }
                  .disabled(cryptoViewModel.plainTextURL == nil ||
                            cryptoViewModel.cipherTextURL == nil ||
                            HLPrimeType(cryptoViewModel.calculatedKeyString) == nil)

                .padding(.bottom)

                  Button(action: {
                      self.cryptoViewModel.decode()
                  }) {
                      Text("Decode")
                  }
                  .disabled(cryptoViewModel.cipherTextURL == nil ||
                            cryptoViewModel.decipherTextURL == nil ||
                            HLPrimeType(cryptoViewModel.calculatedKeyString) == nil)
              }
              
        }
        .padding()
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
