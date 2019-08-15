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
    let fileManager: HLFileManager = HLFileManager.sharedInstance()
    
    var pTable: [HLPrimeType] = []  //  used to find / validate primes
    var timeInSeconds = 0     //  time for makePrimes, factorPrimes, or loadBuf to run

    var lastN: Int = 0
    var lastP: HLPrimeType = 0
    var primeFileLastLine: String?

    public func findPrimes(maxPrime: HLPrimeType) {
        print( "\nHLPrime-  findPrimes-  maxPrime: \(maxPrime)" )

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            var output = ""
            
            self.pTable = self.primeTable.createPTable(maxPrime: maxPrime)
            (self.lastN, self.lastP) = (3, 5)   //  this is our starting point
            
            self.fileManager.openPrimesFileForAppend(with: self.primesFileURL.path)
        
 //           print( "HLPrime-  findPrimes-  entering main loop ..." )
            let startDate = Date()  //  don't count the time to create pTable


            //***********************************************************************************
            while( maxPrime >= self.lastP ) {
                if self.isPrime(self.lastP)    {
                    output = String(format: "%d\t%ld\n", self.lastN, self.lastP)
                    self.fileManager.appendPrimesLine(output)
                    self.lastN += 1
                }
                self.lastP += 2
            }
            //***********************************************************************************


            self.timeInSeconds = -Int(startDate.timeIntervalSinceNow)
            self.fileManager.closePrimesFileForAppend()
            self.pTable.removeAll()
            
        DispatchQueue.main.sync { [weak self] in
                guard let self = self else { return }
                output.removeLast()
                self.primeFileLastLine = output
                let (newLastN, newLastP) = output.parseLine()
                print( "findPrimes-  final lastN: \(newLastN)    lastP: \(newLastP)" )

                self.delegate.findPrimesCompleted(lastLine: output)
            }
        }
    }
    
    func isPrime(_ value: HLPrimeType) -> Bool    {
        var candidateIsPrime = true
        let maxTestPrime = Int64(sqrt(Double(value)))
        
        var index = 1   //  we don't try the value in [0] == 2
//        var index = 0   //  we do try the value in [0] == 2
        var testPrime = pTable[index]
        while testPrime <= maxTestPrime {
            let q_r = lldiv(value, testPrime)
            if q_r.rem == 0 {
                candidateIsPrime = false
                break
            }

            index += 1
            guard index < pTable.count else { return true }    //  if we get here, we have exhausted the pTable
            testPrime = pTable[index]
        }
        
//        print( "HLPrime-  isPrime: \(value)   isPrime: \(candidateIsPrime)" )
        return candidateIsPrime
    }

    public init(primesFileURL: URL, delegate: HLPrimesProtocol) {
        print("HLPrime-  init: \(primesFileURL)")
        self.primesFileURL = primesFileURL
        self.delegate = delegate
        
        //  creaate new primeFile with the first 2 entries (2 and 3)
        fileManager.createPrimeFile(with: primesFileURL.path)
    }
}
