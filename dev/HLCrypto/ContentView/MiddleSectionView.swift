//
//  MiddleSectionView.swift
//  HLCrypto
//
//  Created by Matthew Homer on 10/19/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import SwiftUI

struct MiddleSectionView: View {
    @ObservedObject var cryptoViewModel: HLCryptoViewModel
    @State var zeroChosenKeyMessage = false
    @State var zeroPrimePMessage = false
    @State var zeroPrimeQMessage = false
    let HLErrorInvalidDataTitle = "Data in TextField is not valid"
    let HLTextFieldWidth: CGFloat = 100

    var body: some View {
        VStack {
            //**********  Character Set, Chunk Size, and Character Set Size
            HStack {
                Text("Character Set:   ASCII range: ['!' - '}']")
                Spacer()
                Text("Chunk Size:  \(cryptoViewModel.chunkSize)")
                Spacer()
                Text("Character Set Size:  \(cryptoViewModel.characterSetCount)")
            }
            .padding(.top, 15)

            TextField(cryptoViewModel.characterSet, text: $cryptoViewModel.characterSet, onCommit: {
                self.cryptoViewModel.setupRSA() //  need to recalculate characterSetCount and chunkSize
            })
            .lineLimit(2)
            .padding(.bottom, 15)
         
            VStack {
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
                  .padding(.horizontal, 20)
                  Spacer()
              }
                .alert(isPresented: $zeroChosenKeyMessage) {
                    Alert(title: Text(HLErrorInvalidDataTitle), message: Text("'Chosen Key' value must be prime > 2 and less than (p-1)*(q-1)"))}
                .padding(.bottom)
        }
    }
    }
}

struct MiddleSectionView_Previews: PreviewProvider {
    static var previews: some View {
        MiddleSectionView(cryptoViewModel: HLCryptoViewModel())
    }
}
