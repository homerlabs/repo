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

    let characterSet = "-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcdefghijklmnopqrstuvwxyz"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSingleChunk() {
        let rsa = HLRSA(p: 503, q: 983, characterSet: characterSet)
 //       let secretKey: HLPrimeType = 36083
        let secretKey: HLPrimeType = 300023
        let calculatedKey = rsa.calculateKey(publicKey: secretKey)
        let plaintextChunk = "90"
        
        let cipherChunk = rsa.encodeString(input: plaintextChunk, encodeKey: secretKey, decodeKey: calculatedKey)
        let deCipherChunk = rsa.encodeString(input: cipherChunk, encodeKey: calculatedKey, decodeKey: secretKey)
        
        XCTAssert(plaintextChunk == deCipherChunk, "testInt '\(plaintextChunk)' converted back to '\(deCipherChunk)'")
    }

    func testIntToStringBackToInt() {
        let rsa = HLRSA(p: 503, q: 983, characterSet: characterSet)
        let initialInts: [HLPrimeType] = [1451, 91413]
        
        for testInt in initialInts {
            let str = rsa.intToString(n: testInt)
            let finalInt = rsa.stringToInt(text: str)
            print("testInt: \(testInt)  str: \(str)")
            if testInt != finalInt {
                XCTAssert(false, "testInt '\(testInt)' converted back to '\(finalInt)'")
            }
        }
        
        XCTAssert(true)
    }

    func testEncodeDecodeSingleInt() {
        let rsa = HLRSA(p: 503, q: 983, characterSet: characterSet)
        let secretKey: HLPrimeType = 36083
        let calculatedKey = rsa.calculateKey(publicKey: secretKey)
        let initialInts: [HLPrimeType] = [1, 42, 24, 10000, 100]
        
        for testInt in initialInts {
            let encodedValue = rsa.encode(m: testInt, key: secretKey)
            let decodedValue = rsa.encode(m: encodedValue, key: calculatedKey)
            if testInt != decodedValue {
                XCTAssert(false, "testInt '\(testInt)' encodedValue '\(encodedValue)' converted back to '\(decodedValue)'")
            }
        }
        
        XCTAssert(true)
    }

    func testCalculateKey() {
        let p: HLPrimeType = 251
        let q: HLPrimeType = 257
        let secretKey: HLPrimeType = 101
        let publicKey: HLPrimeType = 1901
        let rsa = HLRSA(p: p, q: q, characterSet: characterSet)
        let calculatedKey = rsa.calculateKey(publicKey: secretKey)
        XCTAssert(calculatedKey == publicKey, "calculatedKey was '\(calculatedKey)', should have been '\(publicKey)'")
    }
}
