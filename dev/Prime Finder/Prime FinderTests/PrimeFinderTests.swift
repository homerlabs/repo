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

    var primeFinder = HLPrime()
    var primesURL: URL?
    public static let HLPrimesBookmarkKey  = "HLPrimesBookmarkKey"
    let HLSavePanelTitle = "Prime Finder Tests Save Panel"
    let maxPrime: HLPrimeType = 10000000

    override func setUp() {
        primesURL = HLPrime.HLPrimesBookmarkKey.getBookmark()
        if primesURL == nil {
            let path = "TestPrimes"
            primesURL = path.getSaveFilePath(title: HLSavePanelTitle, message: "Set Primes file path")
            print("primesURL: \(String(describing: primesURL))")
        }
        
        primeFinder.primesFileURL = primesURL
    }

    override func tearDown() {
        if let url = primesURL {
            url.setBookmarkFor(key: HLPrime.HLPrimesBookmarkKey)
        }
        primesURL?.stopAccessingSecurityScopedResource()
    }

    func testPTableCreateSmall() {
        let maxPrime: HLPrimeType = 1000
        let pTableCount = 11
        let pTable = primeFinder.createPTable(maxPrime: maxPrime)
        print("pTable: \(pTable.count)")
        XCTAssert(pTable.count == pTableCount, "pTable.count was '\(pTable.count)', should have been '\(pTableCount)'")
    }

    func testPTableCreateBig() {
        let maxPrime: HLPrimeType = 100000000
        let pTableCount = 1229
        let pTable = primeFinder.createPTable(maxPrime: maxPrime)
        print("pTable: \(pTable.count)")
        XCTAssert(pTable.count == pTableCount, "pTable.count was '\(pTable.count)', should have been '\(pTableCount)'")
    }


    func testPrimeFinder() {
        let startTime = Date()
        let expectationFindPrimes = XCTestExpectation(description: "FindPrimes Expectation")
        
        primeFinder.findPrimes(maxPrime: maxPrime) { [weak self] result in
            guard let self = self else { return }
            
            print("self: \(self)")
            print("result: \(result)")
            let totalTime = -startTime.timeIntervalSinceNow
            print("***********************  totalTime: \(totalTime.formatString(digits: 1)) seconds)")
            expectationFindPrimes.fulfill()
            
        }
        
        wait(for: [expectationFindPrimes], timeout: 100)
//        XCTAssert(false, "findPrimes() did not run to completion!")
    }

/*    func testPerformanceExample() {
        
        self.measure {
            primeFinder.findPrimes(maxPrime: 1000) { [weak self] result in
                guard let self = self else { return }
                
                print("self: \(self)")
                print("result: \(result)")
            }
        }
    }   */
}
