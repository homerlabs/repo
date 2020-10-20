//
//  BottomSectionView.swift
//  HLCrypto
//
//  Created by Matthew Homer on 10/19/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import SwiftUI

struct BottomSectionView: View {
    @ObservedObject var cryptoViewModel: HLCryptoViewModel
    
    var body: some View {
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
 //     .padding()
 //     .background(windowBackgroundColor)
//      .onAppear() {
 //         self.cryptoViewModel.setupRSA()
  //    }
  //    .frame(minWidth: appWidth, minHeight: appHeight)
//    }
}

struct BottomSectionView_Previews: PreviewProvider {
    static var previews: some View {
        BottomSectionView(cryptoViewModel: HLCryptoViewModel())
    }
}
