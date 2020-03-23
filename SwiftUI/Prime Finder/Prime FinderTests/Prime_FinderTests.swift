//
//  Prime_FinderTests.swift
//  Prime FinderTests
//
//  Created by Matthew Homer on 2/20/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import XCTest
@testable import Prime_Finder

class Prime_FinderTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPTableCreateSmall() {
        if let url = URL(string: "Primes.txt") {
            let pFinder = HLPrime(primesFileURL: url)
            let maxPrime: HLPrimeType = 1000
            let pTableCount = 11
            let pTable = pFinder.createPTable(maxPrime: maxPrime)
            print("pTable: \(pTable.count)")
            XCTAssert(pTable.count == pTableCount, "pTable.count was '\(pTable.count)', should have been '\(pTableCount)'")
        }
    }

    func testPTableCreateBig() {
        if let url = URL(string: "Primes.txt") {
            let pFinder = HLPrime(primesFileURL: url)
            let maxPrime: HLPrimeType = 100000000
            let pTableCount = 1229
            let pTable = pFinder.createPTable(maxPrime: maxPrime)
            print("pTable: \(pTable.count)")
            XCTAssert(pTable.count == pTableCount, "pTable.count was '\(pTable.count)', should have been '\(pTableCount)'")
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
