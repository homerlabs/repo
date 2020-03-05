//
//  HLCryptoViewModel.swift
//  HLCrypto
//
//  Created by Matthew Homer on 2/25/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import Foundation

class HLCryptoViewModel: ObservableObject {
    @Published var plainTextURL: URL?
    @Published var cipherTextURL: URL?
    @Published var decipherTextURL: URL?
    @Published var pString = "257"
    @Published var qString = "251"
    @Published var chosenKeyString = "36083"
    @Published var calculatedKeyString = "0"
    @Published var characterSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcdefghijklmnopqrstuvwxyz"
    @Published var characterSetCountString = "0"

    @Published var pqString = "0"
    @Published var gammaString = "0"
    @Published var chunkSize = "0.0"

    let HLPlainTextPathKey      = "PlainTextPathKey"
    let HLCipherTextPathKey     = "CipherTextPathKey"
    let HLDeCipherTextPathKey   = "DeCipherTextPathKey"
    let HL_PKey                 = "RSA_PKey"
    let HL_QKey                 = "RSA_QKey"

    @Published var rsa: HLRSA?
    
    func setupKeys() {
        if let publicKey = HLPrimeType(chosenKeyString) {
            let privateKey = rsa!.calculateKey(publicKey: publicKey)
            rsa?.keyPublic = publicKey
            rsa?.keyPrivate = privateKey
            calculatedKeyString = String(privateKey)
        }
    }
    
    func setupRSA() {
        let p = HLPrimeType(pString)
        let q = HLPrimeType(qString)
        guard p != nil, q != nil else { return }
        
        pqString = String(p! * q!)
        gammaString = String((p!-1) * (q!-1))
        characterSetCountString = String(characterSet.count)
        
        rsa = HLRSA(p: p!, q: q!, characterSet: characterSet)
        chunkSize = String.init(format: "%0.1f", arguments: [rsa!.chunkSizeDouble])

        setupKeys()
    }

    init() {
        print("HLCryptoViewModel-  init")
        plainTextURL = HLPlainTextPathKey.getBookmark()
        cipherTextURL = HLCipherTextPathKey.getBookmark()
        decipherTextURL = HLDeCipherTextPathKey.getBookmark()
        
        let valueP = UserDefaults.standard.integer(forKey: HL_PKey)
        if valueP != 0 {
            pString = String(valueP)
        }
        
        let valueQ = UserDefaults.standard.integer(forKey: HL_QKey)
        if valueQ != 0 {
            qString = String(valueQ)
        }
    }
    
    deinit {
        print("HLCryptoViewModel-  deinit")
        if let url = plainTextURL {
            url.setBookmarkFor(key: HLPlainTextPathKey)
        }
        
        if let url = cipherTextURL {
            url.setBookmarkFor(key: HLCipherTextPathKey)
        }
        
        
        if let url = decipherTextURL {
            url.setBookmarkFor(key: HLDeCipherTextPathKey)
        }
        
        if let value = HLPrimeType(pString) {
            UserDefaults.standard.set(value, forKey: HL_PKey)
        }
        
        if let value = HLPrimeType(qString) {
            UserDefaults.standard.set(value, forKey: HL_QKey)
        }
        
        plainTextURL?.stopAccessingSecurityScopedResource()
        cipherTextURL?.stopAccessingSecurityScopedResource()
        decipherTextURL?.stopAccessingSecurityScopedResource()
    }
}
