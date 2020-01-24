//
//  PrimeFinderTests.swift
//  PrimeFinderTests
//
//  Created by Matthew Homer on 12/23/17.
//  Copyright © 2017 Matthew Homer. All rights reserved.
//

import XCTest
//import HLPrime

class PrimeFinderTests: XCTestCase {

    var primeFinder: HLPrime?
    var primesURL: URL?
    var currentExpectation: XCTestExpectation?
    
    let hightestPrime: HLPrimeType = 100000
    let timeout: TimeInterval = 10


    //*************   HLPrimeProtocol     *********************************************************
/*    func findPrimesCompleted(lastLine: String) {
        print( "findPrimesCompleted-  lastLine: \(lastLine)" )
        currentExpectation?.fulfill()
    }
    
    func findNicePrimesCompleted(lastLine: String) {
        currentExpectation?.fulfill()
    }*/
    //*************   HLPrimeProtocol     *********************************************************
 

    override func setUp() {
        super.setUp()
        
        if primesURL == nil {
            let path = "/Volumes/USB64/Primes.txt"
            primesURL = path.getSaveFilePath(title: "PrimeFinder Save Panel", message: "Set Primes file path for test")
        }
        
        if primesURL != nil {
            primeFinder = HLPrime(primesFileURL: primesURL!)
            primesURL?.setBookmarkFor(key: HLPrime.HLPrimesBookmarkKey)
        }
    }
    
    override func tearDown() {
        primeFinder = nil
        currentExpectation = nil
        super.tearDown()
    }
    
    func testPrimes() {
        currentExpectation = expectation(description: "Primes passed")
        primeFinder!.findPrimes(maxPrime: hightestPrime, completion: { [weak self] result in
            guard let self = self else { return }
        
            let (lastN, lastP) = result.parseLine()
            print( "    *********   testPrimes completed    result: \(result)" )
            print( "    *********   testPrimes completed    \(lastN) : \(lastP)" )

            self.currentExpectation?.fulfill()

/*           let elaspsedTime = self.primeFinder!.timeInSeconds.formatTime()
            print( "    *********   findPrimes completed in \(elaspsedTime)    *********\n" )
            self.findPrimesInProgress = false
            let (lastN, lastP) = result.parseLine()
            self.progressTextField.stringValue = "\(lastN) : \(lastP)"
            self.primeButton.title = self.primesButtonTitle
            self.nicePrimesButton.isEnabled = true
            self.timer?.invalidate()*/
        })
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        wait(for: [currentExpectation!], timeout: timeout)
        print( "    *********   testPrimes completed" )
    }
}
