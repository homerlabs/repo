//
//  RSAToolTests.swift
//  RSAToolTests
//
//  Created by Matthew Homer on 11/3/17.
//  Copyright © 2017 Matthew Homer. All rights reserved.
//

import XCTest

class RSAToolTests: XCTestCase {

    let rsa = HLRSA(p: 5087, q: 4547)
    let kPublic = Int64(72167)
    let kPrivate = Int64(2913227)

    override func setUp() {
        super.setUp()
        rsa.keyPublic = kPublic
        rsa.keyPrivate = kPrivate
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStringToInt() {
        let messageString = "12345"
        let messageInt = rsa.stringToInt(text: messageString)
        let newString = rsa.intToString(n: messageInt)
        print( "messageString: \(messageString)    messageInt: \(messageInt)    newString: \(newString)" )
        XCTAssertEqual(messageString, newString, "\(messageString) does not equal \(newString)")
    }
    
    func testEncodeDecode() {
        let plaintextInt = Int64(10)
        let cypherInt = rsa.encode(m: plaintextInt, key: rsa.keyPublic)
        let decypherInt = rsa.encode(m: cypherInt, key: rsa.keyPrivate)
        print( "plaintextInt: \(plaintextInt)    cypherInt: \(cypherInt)    decypherInt: \(decypherInt)" )
        XCTAssertEqual(plaintextInt, decypherInt, "\(plaintextInt) does not equal \(decypherInt)")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
