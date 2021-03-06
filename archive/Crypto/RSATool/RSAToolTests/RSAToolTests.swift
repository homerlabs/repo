//
//  RSAToolTests.swift
//  RSAToolTests
//
//  Created by Matthew Homer on 11/3/17.
//  Copyright © 2017 Matthew Homer. All rights reserved.
//

import XCTest

class RSAToolTests: XCTestCase {

    var rsa: HLRSA!
    let kPublic = Int64(72353)
    let kPrivate = Int64(10880397)

    override func setUp() {
        super.setUp()
        rsa = HLRSA(p: 15971, q: 15959, characterSet: "1234567890")
        rsa.keyPublic = kPublic
        rsa.keyPrivate = kPrivate
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStringToInt() {
        let messageString = "1234567"
        let messageInt = rsa.stringToInt(text: messageString)
        let newString = rsa.intToString(n: messageInt)
        print( "messageString: \(messageString)    messageInt: \(messageInt)    newString: \(newString)" )
        XCTAssertEqual(messageString, newString, "\(messageString) does not equal \(newString)")
    }
    
    func testEncodeDecode() {
        for testInt in 1..<250000000 {
     //       let plaintextInt = Int64(23130590)
            let plaintextInt = Int64(testInt)
            let cypherInt = rsa.encode(m: plaintextInt, key: rsa.keyPublic)
            let decypherInt = rsa.encode(m: cypherInt, key: rsa.keyPrivate)
            
            if testInt % 1000000 == 1  {
                print( "plaintextInt: \(plaintextInt)    cypherInt: \(cypherInt)    decypherInt: \(decypherInt)" )
            }
            
            XCTAssertEqual(plaintextInt, decypherInt, "\(plaintextInt) does not equal \(decypherInt)")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
