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
    let fileManager = HLFileManager.shared
    let HLSavePanelTitle = "Prime Finder Tests Save Panel"
//    let maxPrime: HLPrimeType = 10000000

    override func setUp() {
        primesURL = fileManager.getBookmark(HLPrime.HLPrimesURLKey)
        if primesURL == nil {
            let path = "TestPrimes"
            primesURL = fileManager.getURLForWritting(title: "Prime Finder Save Panel", message: "Set Primes file path", filename: path)
            print("primesURL: \(String(describing: primesURL))")
        }
    }

    override func tearDown() {
        if let url = primesURL {
            fileManager.setBookmarkForURL(url, key: HLPrime.HLPrimesURLKey)
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
        let maxPrime: HLPrimeType = 1000000
        let startTime = Date()
        let expectationFindPrimes = XCTestExpectation(description: "FindPrimes Expectation")
        
        primeFinder.findPrimes(primeURL: primesURL!, maxPrime: maxPrime) { [weak self] result in
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
