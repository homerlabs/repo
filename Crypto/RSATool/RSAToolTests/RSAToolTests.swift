//
//  RSAToolTests.swift
//  RSAToolTests
//
//  Created by Matthew Homer on 11/3/17.
//  Copyright © 2017 Matthew Homer. All rights reserved.
//

import XCTest

class RSAToolTests: XCTestCase {

    let rsa = HLRSA(p: 5, q: 7)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStringToInt() {
        let messageString = "ZZ"
        let messageInt = rsa.stringToInt(text: messageString)
        let newString = rsa.intToString(n: messageInt)
        print( "messageString: \(messageString)    messageInt: \(messageInt)    newString: \(newString)    " )
        XCTAssertEqual(messageString, newString, "\(messageString) does not equal \(newString)")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
