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

    let characterSet = "-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
//    let characterSet = "0123456789"
    let p1: HLPrimeType = 503
    let q1: HLPrimeType = 983
    let secretKey: HLPrimeType = 300023

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSingleChunk() {
        let rsa = HLRSA(p: p1, q: q1, characterSet: characterSet)
        let calculatedKey = rsa.calculateKey(publicKey: secretKey)
        let plaintextChunk = "DEF"
        
        let cipherChunk = rsa.encodeString(input: plaintextChunk, encodeKey: secretKey, decodeKey: calculatedKey)
        let deCipherChunk = rsa.encodeString(input: cipherChunk, encodeKey: calculatedKey, decodeKey: secretKey)
        
        XCTAssert(plaintextChunk == deCipherChunk, "plaintextChunk '\(plaintextChunk)' converted back to '\(deCipherChunk)'")
    }

    func testStringToInt() {
        let rsa = HLRSA(p: p1, q: q1, characterSet: characterSet)
        let initialStrings = ["DEF"]
        
        for testString in initialStrings {
            let resultInt = rsa.stringToInt(text: testString)
            let finalString = rsa.intToString(n: resultInt)
            print("testString: \(testString)  resultInt: \(resultInt)  finalString: \(finalString)")
            if testString != finalString {
                XCTAssert(false, "testString '\(testString)' converted back to '\(finalString)'")
            }
        }
        
        XCTAssert(true)
    }

    func testIntToString() {
        let rsa = HLRSA(p: p1, q: q1, characterSet: characterSet)
        let initialInts: [HLPrimeType] = [452523]
        
        for testInt in initialInts {
            let str = rsa.intToString(n: testInt)
            let finalInt = rsa.stringToInt(text: str)
            print("testInt: \(testInt)  str: \(str)  finalInt: \(finalInt)")
            if testInt != finalInt {
                XCTAssert(false, "testInt '\(testInt)' converted back to '\(finalInt)'")
            }
        }
        
        XCTAssert(true)
    }

    func testEncodeSingleInt() {
        let rsa = HLRSA(p: p1, q: q1, characterSet: characterSet)
        let calculatedKey = rsa.calculateKey(publicKey: secretKey)
        let initialInts: [HLPrimeType] = [56527]
        
        for testInt in initialInts {
            let encodedValue = rsa.encode(m: testInt, key: secretKey)
            let decodedValue = rsa.encode(m: encodedValue, key: calculatedKey)
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
        let secretKey: HLPrimeType = 101
        let publicKey: HLPrimeType = 1901
        let rsa = HLRSA(p: p, q: q, characterSet: characterSet)
        let calculatedKey = rsa.calculateKey(publicKey: secretKey)
        XCTAssert(calculatedKey == publicKey, "calculatedKey was '\(calculatedKey)', should have been '\(publicKey)'")
    }
}
