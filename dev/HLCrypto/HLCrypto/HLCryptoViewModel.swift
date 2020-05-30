//
//  HLCryptoViewModel.swift
//  HLCrypto
//
//  Created by Matthew Homer on 2/25/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import Foundation
import Cocoa

enum HLErrorEnum {
    case noError
    case fileMissingError
}

class HLCryptoViewModel: ObservableObject {
    @Published var plainTextURL: URL?
    @Published var cipherTextURL: URL?
    @Published var decipherTextURL: URL?
    @Published var primeP: HLPrimeType  = 503
    @Published var primeQ: HLPrimeType  = 983
    @Published var chosenKey: HLPrimeType = 36083
    @Published var calculatedKey: HLPrimeType = 0
    @Published var characterSet = "-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    @Published var characterSetCount = 0

    @Published var pq: HLPrimeType = 0
    @Published var phi: HLPrimeType = 0
    @Published var chunkSize = "0.0"
    
    @Published var plaintextFileMissingMessage = false
    @Published var ciphertextFileMissingMessage = false

    //  these values are arbitrary as the true defaults are set above
    private var rsa: HLRSA!

    let HLPlainTextPathKey      = "PlainTextPathKey"
    let HLCipherTextPathKey     = "CipherTextPathKey"
    let HLDeCipherTextPathKey   = "DeCipherTextPathKey"
    let HL_PKey                 = "RSA_PKey"
    let HL_QKey                 = "RSA_QKey"
    let HL_ChosenKeyKey         = "RSA_ChosenKeyKey"
    let HL_CharacterSetKey      = "RSA_CharacterSetKey"
    
    func encode() {
        plaintextFileMissingMessage = !plainTextURL!.isFilePresent()
        if plaintextFileMissingMessage {
            plainTextURL = nil
        } else {
   //         rsa.makeRandomPlaintextFile(fileURL: plainTextURL!, numberOfCharacters: 5000) //  for testing
            rsa.encodeFile(inputFilepath: plainTextURL!.path, outputFilepath: cipherTextURL!.path)
        }
    }
    
    func decode() {
        ciphertextFileMissingMessage = !cipherTextURL!.isFilePresent()
        if ciphertextFileMissingMessage {
            cipherTextURL = nil
        } else {
            rsa.decodeFile(inputFilepath: cipherTextURL!.path, outputFilepath: decipherTextURL!.path)
        }
    }
    
    func setupKeys() {
        calculatedKey = rsa.calculateKey(publicKey: chosenKey)
        rsa.keyPublic = chosenKey
        rsa.keyPrivate = calculatedKey
}
    
    func setupRSA() {
        guard primeP != 0, primeQ != 0 else { return }
        
        pq = primeP * primeQ
        phi = (primeP - 1) * (primeQ - 1)
        rsa = HLRSA(p: primeP, q: primeQ, publicKey: chosenKey, characterSet: characterSet)
        
        characterSetCount = characterSet.count
        chunkSize = String.init(format: "%0.2f", arguments: [rsa.chunkSizeDouble])

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
        
        if let valueKey = UserDefaults.standard.object(forKey: HL_ChosenKeyKey) as? NSNumber {
            chosenKey = valueKey.int64Value
        }
        
        if let characters = UserDefaults.standard.string(forKey: HL_CharacterSetKey) {
            characterSet = characters
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
        UserDefaults.standard.set(chosenKey, forKey: HL_ChosenKeyKey)
        UserDefaults.standard.set(characterSet, forKey: HL_CharacterSetKey)
        plainTextURL?.stopAccessingSecurityScopedResource()
        cipherTextURL?.stopAccessingSecurityScopedResource()
        decipherTextURL?.stopAccessingSecurityScopedResource()
        NSApplication.shared.terminate(self)    //  quit if view deallocs
    }
}
