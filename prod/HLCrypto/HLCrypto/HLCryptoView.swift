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
    @State var zeroChosenKeyMessage = false
    let HLSavePanelTitle = "HLCrypto Save Panel"
    let HLOpenPanelTitle = "HLCrypto Open Panel"
    let HLErrorInvalidDataTitle = "Data in TextField is not valid"
    let textFieldBackgroundColor = Color(red: 0.9, green: 0.9, blue: 0.9)
    let windowBackgroundColor = Color(red: 0.85, green: 0.89, blue: 0.91)
    let HLTextFieldWidth: CGFloat = 100
    let appWidth: CGFloat = 620
    let appHeight: CGFloat = 346

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
           
            VStack {
                //**********  Character Set, Chunk Size, and Character Set Size
                HStack {
                    Text("Character Set:   ASCII range: ['!' - '}']")
                    Spacer()
                    Text("Chunk Size:  \(cryptoViewModel.chunkSize)")
                    Spacer()
                    Text("Character Set Size:  \(cryptoViewModel.characterSetCount)")
                }
                
                TextField(cryptoViewModel.characterSet, text: $cryptoViewModel.characterSet, onCommit: {
                    self.cryptoViewModel.setupRSA() //  need to recalculate characterSetCount and chunkSize
                })
                .lineLimit(2)
            }
             .padding(.vertical)
             
            Form {
              //**********  set P, Q
              HStack {
                  Text("P:")
                  TextField(String(cryptoViewModel.primeP), value: $cryptoViewModel.primeP, formatter: NumberFormatter(), onCommit: {
                        if self.cryptoViewModel.primeP != 0 {
                            self.cryptoViewModel.setupRSA()
                        } else {
                            self.zeroPrimePMessage = true
                        }
                  })
                    .alert(isPresented: $zeroPrimePMessage) {
                        Alert(title: Text(HLErrorInvalidDataTitle), message: Text("'P' value must be a non-zero integer"))}
                    .frame(width: HLTextFieldWidth)
                  Spacer()
                  
                  Text("Q:")
                  TextField(String(cryptoViewModel.primeQ), value: $cryptoViewModel.primeQ, formatter: NumberFormatter(), onCommit: {
                        if self.cryptoViewModel.primeQ != 0 {
                            self.cryptoViewModel.setupRSA()
                        } else {
                            self.zeroPrimeQMessage = true
                        }
                  })
                    .alert(isPresented: $zeroPrimeQMessage) {
                        Alert(title: Text(HLErrorInvalidDataTitle), message: Text("'Q' value must be a non-zero integer"))}
                    .frame(width: HLTextFieldWidth)
                  Spacer()
                  
                  Text("P*Q:  \(cryptoViewModel.pq)")
                  Spacer()
                  Text("(P-1)(Q-1):  \(cryptoViewModel.phi)")
              }

              //**********  set chosenKey
              HStack {
                  Text("Chosen Key:")
                  TextField(String(cryptoViewModel.chosenKey), value: $cryptoViewModel.chosenKey, formatter: NumberFormatter(), onCommit: {
                        if self.cryptoViewModel.chosenKey > 0 && self.cryptoViewModel.chosenKey < self.cryptoViewModel.phi {
                            self.cryptoViewModel.setupKeys()
                        } else {
                             self.zeroChosenKeyMessage = true
                             self.cryptoViewModel.chosenKey = 3
                        }
                  })
                    .frame(width: HLTextFieldWidth)
                  
       //           Spacer()
                  Text("Calculated Key:  \(cryptoViewModel.calculatedKey)")
                  .padding(.horizontal)
                  Spacer()
              }
                .alert(isPresented: $zeroChosenKeyMessage) {
                    Alert(title: Text(HLErrorInvalidDataTitle), message: Text("'Chosen Key' value must be prime > 2 and less than (p-1)*(q-1)"))}
                .padding(.bottom)
        }

          //  Encode and Decode Buttons
          VStack {
            Button(action: {
                self.cryptoViewModel.encode()
            }) {
                Text("Encrypt")
            }
            .alert(isPresented: $cryptoViewModel.plaintextFileMissingMessage) {
                Alert(title: Text("Serious Error!"), message: Text("Plaintext file missing!"))}
            .disabled(cryptoViewModel.plainTextURL == nil ||
                    cryptoViewModel.cipherTextURL == nil ||
                    !cryptoViewModel.plainTextURL!.isFilePresent() ||
                    cryptoViewModel.calculatedKey < 1)

            .padding(.bottom, 8)

              Button(action: {
                  self.cryptoViewModel.decode()
              }) {
                  Text("Decrypt")
              }
              .alert(isPresented: $cryptoViewModel.ciphertextFileMissingMessage) {
                  Alert(title: Text("Serious Error!"), message: Text("Ciphertext file missing!"))}
              .disabled(cryptoViewModel.cipherTextURL == nil ||
                    cryptoViewModel.decipherTextURL == nil ||
                    !cryptoViewModel.cipherTextURL!.isFilePresent() ||
                    cryptoViewModel.calculatedKey < 1)
          }
              
        }
        .padding()
        .background(windowBackgroundColor)
        .onAppear() {
            self.cryptoViewModel.setupRSA()
        }
        .frame(minWidth: appWidth, minHeight: appHeight)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HLCryptoView()
    }
}
