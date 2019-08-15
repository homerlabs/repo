//
//  PrimeFinderTests.swift
//  PrimeFinderTests
//
//  Created by Matthew Homer on 12/23/17.
//  Copyright © 2017 Matthew Homer. All rights reserved.
//

import XCTest

class PrimeFinderTests: XCTestCase, HLPrimesProtocol {

    var primeFinder: HLPrime?
    var currentExpectation: XCTestExpectation?
    
    let hightestPrime: HLPrimeType = 100000
    let timeout: TimeInterval = 10


    //*************   HLPrimeProtocol     *********************************************************
    func findPrimesCompleted(lastLine: String) {
        currentExpectation?.fulfill()
    }
    
    func findNicePrimesCompleted(lastLine: String) {
        currentExpectation?.fulfill()
    }
    //*************   HLPrimeProtocol     *********************************************************
    

    override func setUp() {
        super.setUp()
        primeFinder = HLPrime(primeFilePath: "/Volumes/USB64/Primes", delegate: self)
    }
    
    override func tearDown() {
        primeFinder = nil
        currentExpectation = nil
        super.tearDown()
    }
    
    func testPrimes() {
        currentExpectation = expectation(description: "Primes passed")
        primeFinder!.findPrimes(largestPrime: hightestPrime)
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        wait(for: [currentExpectation!], timeout: timeout)
        print( "    *********   testPrimes completed" )
    }
    
    func testFactorer() {
        currentExpectation = expectation(description: "Factorer passed")
        primeFinder!.factorPrimes(largestPrime: hightestPrime)
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        wait(for: [currentExpectation!], timeout: timeout)
        print( "    *********   testFactorer completed" )
    }    
}
