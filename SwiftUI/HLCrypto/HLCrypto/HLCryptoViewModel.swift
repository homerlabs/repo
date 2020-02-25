//
//  HLCryptoViewModel.swift
//  HLCrypto
//
//  Created by Matthew Homer on 2/25/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import Foundation

class HLCryptoViewModel: ObservableObject {
    @Published var plainTextPath = "Plaintext Path not set"
    @Published var cipherTextPath = "Ciphertext Path not set"
    @Published var decipherTextPath = "DeCiphertext Path not set"
    @Published var pString = "3"
    @Published var qString = "5"
    @Published var chosenKeyString = "7"
    
    var rsa: HLRSA?
    
    func pMinus1QMinus1() -> Int {
        guard let p = Int(pString) else { return 0 }
        guard let q = Int(qString) else { return 0 }
        return (p-1) * (q-1)
    }
    
    func pTimesQ() -> Int {
        guard let p = Int(pString) else { return 0 }
        guard let q = Int(qString) else { return 0 }
        return p * q
    }
}
