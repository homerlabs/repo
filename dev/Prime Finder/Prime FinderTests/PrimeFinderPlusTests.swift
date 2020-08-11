//
//  Prime_FinderTests.swift
//  Prime FinderTests
//
//  Created by Matthew Homer on 2/20/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import XCTest
@testable import Prime_Finder

class PrimeFinderPlusTests: XCTestCase {

    var primeFinder = HLPrime()
    var primesURL: URL?
    public static let HLPrimesBookmarkKey  = "HLPrimesBookmarkKey"
    let HLSavePanelTitle = "Prime Finder Tests Save Panel"
    let maxPrime: HLPrimeType = 100000000
    let waitTime: TimeInterval = 1000

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
        
        wait(for: [expectationFindPrimes], timeout: waitTime)
    }

    func testPrimeFinder2() {
        let startTime = Date()
        let expectationFindPrimes = XCTestExpectation(description: "FindPrimes Expectation")
        
        primeFinder.findPrimes2(maxPrime: maxPrime) { [weak self] result in
            guard let self = self else { return }
            
            print("self: \(self)")
            print("result: \(result)")
            let totalTime = -startTime.timeIntervalSinceNow
            print("***********************  totalTime: \(totalTime.formatString(digits: 1)) seconds)")
            expectationFindPrimes.fulfill()
            
        }
        
        wait(for: [expectationFindPrimes], timeout: waitTime)
    }

    func testPrimeFinder3() {
        let startTime = Date()
        let expectationFindPrimes = XCTestExpectation(description: "FindPrimes Expectation")
        
        primeFinder.findPrimes3(maxPrime: maxPrime) { [weak self] result in
            guard let self = self else { return }
            
            print("self: \(self)")
            print("result: \(result)")
            let totalTime = -startTime.timeIntervalSinceNow
            print("***********************  totalTime: \(totalTime.formatString(digits: 1)) seconds)")
            expectationFindPrimes.fulfill()
            
        }
        
        wait(for: [expectationFindPrimes], timeout: 100)
    }
}
