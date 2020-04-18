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

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testIntToStringBackToInt() {
        let rsa = HLRSA(p: 503, q: 983, characterSet: "1234567890")
        let initialInts: [HLPrimeType] = [1, 42, 24, 10000, 100]
        
        for testInt in initialInts {
            let str = rsa.intToString(n: testInt)
            let finalInt = rsa.stringToInt(text: str)
            if testInt != finalInt {
                XCTAssert(false, "testInt '\(testInt)' converted back to '\(finalInt)'")
            }
        }
        
        XCTAssert(true)
    }

    func testEncodeDecodeSingleInt() {
        let characterSet = "-ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcdefghijklmnopqrstuvwxyz"
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
        let characterSet = "1234567890"
        let rsa = HLRSA(p: p, q: q, characterSet: characterSet)
        let calculatedKey = rsa.calculateKey(publicKey: secretKey)
        XCTAssert(calculatedKey == publicKey, "calculatedKey was '\(calculatedKey)', should have been '\(publicKey)'")
    }
}
