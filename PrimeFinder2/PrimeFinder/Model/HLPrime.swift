//
//  HLPrime.swift
//  Prime Finder
//
//  Created by Matthew Homer on 8/13/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

import Foundation

public typealias HLPrimeType = Int64

public protocol HLPrimesProtocol {
    func findPrimesCompleted(lastLine: String)
    func findNicePrimesCompleted(lastLine: String)
}

public class HLPrime {

    let primesFileURL: URL
    var nicePrimesFileURL: URL?
    let delegate: HLPrimesProtocol
    let primeTable = HLPrimeTable()
    let fileManager: HLFileManager = HLFileManager.shared()
    
    var primeFILE: __sFILE?

    var pTable: [HLPrimeType] = []  //  used to find / validate primes
    var timeInSeconds = 0     //  time for makePrimes, factorPrimes, or loadBuf to run
    
    public func findPrimes(maxPrime: HLPrimeType) {
        print("HLPrime-  findPrimes-  maxPrime: \(maxPrime)")
        pTable = primeTable.createPTable(maxPrime: maxPrime)
        
        delegate.findPrimesCompleted(lastLine: "123")
    }
    
    public init(primesFileURL: URL, delegate: HLPrimesProtocol) {
        print("HLPrime-  init: \(primesFileURL)")
        self.primesFileURL = primesFileURL
        self.delegate = delegate
        
        let _ = fileManager.createPrimeFileIfNeeded(with: primesFileURL.path)
    }
}
