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

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
