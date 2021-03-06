//
//  HLCryptoTests.swift
//  HLCryptoTests
//
//  Created by Matthew Homer on 2/25/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import XCTest
@testable import HLCrypto

class HLCryptoTests: XCTestCase {

    var characterSet = "!ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcdefghijklmnopqrstuvwyz-+=*/[]{}?"
//    let characterSet = "0123456789"
    let p1: HLPrimeType = 30011
    let q1: HLPrimeType = 30707
    let publicKey: HLPrimeType = 6520511

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCharacterSetValid() {
        let valid = HLRSA.validateCharacterSet(characterSet: &characterSet)
        XCTAssert(valid, "testCharacterSetValid failed with valid characterSet")
        
        var characterSetWithDuplicate = "12345678900"
        let notValid = !HLRSA.validateCharacterSet(characterSet: &characterSetWithDuplicate)
        XCTAssert(notValid, "testCharacterSetValid failed with valid characterSet")
    }

    func testLargeRandomString() {
        let rsa = HLRSA(p: p1, q: q1, publicKey: publicKey, characterSet: characterSet)
        var randomPlaintext = rsa.makeRandomPlaintextString(numberOfCharacters: 1000)
        
        var cipherString = rsa.encodeString(&randomPlaintext)
        let deCipherString = rsa.decodeString(&cipherString)
        
        XCTAssert(randomPlaintext == deCipherString, "randomPlaintext '\(randomPlaintext)' converted back to '\(deCipherString)'")
    }

    func testSingleChunk() {
        let rsa = HLRSA(p: p1, q: q1, publicKey: publicKey, characterSet: characterSet)
        var plaintextChunk = "!"
        
        var cipherChunk = rsa.encodeString(&plaintextChunk)
        let deCipherChunk = rsa.decodeString(&cipherChunk)
        
        XCTAssert(plaintextChunk == deCipherChunk, "plaintextChunk '\(plaintextChunk)' converted back to '\(deCipherChunk)'")
    }

    func testStringToInt() {
        let rsa = HLRSA(p: p1, q: q1, publicKey: publicKey, characterSet: characterSet)
        let initialStrings = ["1", "11"]
        
        for testString in initialStrings {
            let resultInt = rsa.stringToInt(testString)
            let finalString = rsa.intToString(resultInt)
            print("testString: \(testString)  resultInt: \(resultInt)  finalString: \(finalString)")
            if testString != finalString {
                XCTAssert(false, "testString '\(testString)' converted back to '\(finalString)'")
            }
        }
        
        XCTAssert(true)
    }

    func testIntToString() {
        let rsa = HLRSA(p: p1, q: q1, publicKey: publicKey, characterSet: characterSet)
        let initialInts: [HLPrimeType] = [452523]
        
        for testInt in initialInts {
            let str = rsa.intToString(testInt)
            let finalInt = rsa.stringToInt(str)
            print("testInt: \(testInt)  str: \(str)  finalInt: \(finalInt)")
            if testInt != finalInt {
                XCTAssert(false, "testInt '\(testInt)' converted back to '\(finalInt)'")
            }
        }
        
        XCTAssert(true)
    }

    func testEncodeSingleInt() {
        let rsa = HLRSA(p: p1, q: q1, publicKey: publicKey, characterSet: characterSet)
        let initialInts: [HLPrimeType] = [11]
        
        for testInt in initialInts {
            let encodedValue = rsa.encode(m: testInt, key: rsa.keyPublic)
            let decodedValue = rsa.encode(m: encodedValue, key: rsa.keyPrivate)
            print("testInt: \(testInt)  encodedValue: \(encodedValue)  decodedValue: \(decodedValue)")
            if testInt != decodedValue {
                XCTAssert(false, "testInt '\(testInt)' encodedValue '\(encodedValue)' converted back to '\(decodedValue)'")
            }
        }
        
        XCTAssert(true)
    }

    func testCalculateKey() {
        let p: HLPrimeType = 251
        let q: HLPrimeType = 257
        let publicKey: HLPrimeType = 1901
        let rsa1 = HLRSA(p: p, q: q, publicKey: publicKey, characterSet: characterSet)
        let rsa2 = HLRSA(p: p, q: q, publicKey: rsa1.keyPrivate, characterSet: characterSet)
        XCTAssert(rsa2.keyPrivate == rsa1.keyPublic, "calculatedKey was '\(rsa2.keyPrivate)', should have been '\(rsa1.keyPublic)'")
    }
}
