//
//  HLCryptoViewModel.swift
//  HLCrypto
//
//  Created by Matthew Homer on 2/25/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import Foundation
import Cocoa

class HLCryptoViewModel: ObservableObject {
    @Published var plainTextURL: URL?
    @Published var cipherTextURL: URL?
    @Published var decipherTextURL: URL?
    @Published var primeP = HLPrimeType(257)
    @Published var primeQ = HLPrimeType(253)
    @Published var chosenKey = HLPrimeType(36083)
    @Published var calculatedKeyString = "0"
    @Published var characterSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcdefghijklmnopqrstuvwxyz"
    @Published var characterSetCountString = "0"

    @Published var pqString = "0"
    @Published var gammaString = "0"
    @Published var chunkSize = "0.0"

    private var rsa: HLRSA?

    let HLPlainTextPathKey      = "PlainTextPathKey"
    let HLCipherTextPathKey     = "CipherTextPathKey"
    let HLDeCipherTextPathKey   = "DeCipherTextPathKey"
    let HL_PKey                 = "RSA_PKey"
    let HL_QKey                 = "RSA_QKey"
    
    func encode() {
     //   setupRSA()
        rsa?.encodeFile(inputFilepath: plainTextURL!.path, outputFilepath: cipherTextURL!.path)
    }
    
    func decode() {
    //    setupRSA()
        rsa?.decodeFile(inputFilepath: cipherTextURL!.path, outputFilepath: decipherTextURL!.path)
    }
    
    func setupKeys() {
        let privateKey = rsa!.calculateKey(publicKey: chosenKey)
        rsa?.keyPublic = chosenKey
        rsa?.keyPrivate = privateKey
        privateKey == -1 ? (calculatedKeyString = "CHOSEN KEY IS INVALID!") : (calculatedKeyString = String(privateKey))
}
    
    func setupRSA() {
  //      let p = HLPrimeType(pString)
   //     let q = HLPrimeType(qString)
  //      guard primeQ != nil, primeQ != nil else { return }
        guard primeP != 0, primeQ != 0 else { return }
        
        pqString = String(primeP * primeQ)
        gammaString = String((primeP-1) * (primeQ-1))
        characterSetCountString = String(characterSet.count)
        
        rsa = HLRSA(p: primeP, q: primeQ, characterSet: characterSet)
        chunkSize = String.init(format: "%0.1f", arguments: [rsa!.chunkSizeDouble])

        setupKeys()
    }

    init() {
        print("HLCryptoViewModel-  init")
        plainTextURL = HLPlainTextPathKey.getBookmark()
        cipherTextURL = HLCipherTextPathKey.getBookmark()
        decipherTextURL = HLDeCipherTextPathKey.getBookmark()
        
        if let valueP = UserDefaults.standard.object(forKey: HL_PKey) as? NSNumber {
            primeP = valueP.int64Value
        }
        
        if let valueQ = UserDefaults.standard.object(forKey: HL_QKey) as? NSNumber {
            primeQ = valueQ.int64Value
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
        
        UserDefaults.standard.set(primeP, forKey: HL_PKey)
        UserDefaults.standard.set(primeQ, forKey: HL_QKey)
        plainTextURL?.stopAccessingSecurityScopedResource()
        cipherTextURL?.stopAccessingSecurityScopedResource()
        decipherTextURL?.stopAccessingSecurityScopedResource()
        NSApplication.shared.terminate(self)    //  quit if app deallocs
    }
}
