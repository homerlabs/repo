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

    let delegate: HLPrimesProtocol  //  set during init()
    let primesFileURL: URL          //  set during init()
    var nicePrimesFileURL: URL?
    let fileManager: HLFileManager = HLFileManager.sharedInstance()

    var pTable: [HLPrimeType] = [2, 3]  //  starts out with the first 2 primes, used to find / validate primes
    var startDate: Date!    //  used to calculate timeInSeconds
    var timeInSeconds = 0   //  time for makePrimes, factorPrimes, or loadBuf to run

    var lastN: Int = 0
    var lastP: HLPrimeType = 0
    var lastLine = ""
    var okToRun = true  //  used to exit big loop before app exits

    public func findPrimes(maxPrime: HLPrimeType) {
        print( "\nHLPrime-  findPrimes-  maxPrime: \(maxPrime)" )

        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            
            self.pTable = self.createPTable(maxPrime: maxPrime)
            (self.lastN, self.lastP) = (3, 5)   //  this is our starting point
            
            self.fileManager.createPrimesFileForAppend(with: self.primesFileURL.path)
        
 //           print( "HLPrime-  findPrimes-  entering main loop ..." )
            self.startDate = Date()  //  don't count the time to create pTable


            //***********************************************************************************
            while( maxPrime >= self.lastP && self.okToRun ) {
                if self.isPrime(self.lastP)    {
                    self.lastLine = String(format: "%d\t%ld\n", self.lastN, self.lastP)
                    self.fileManager.appendPrimesLine(self.lastLine)
                    self.lastN += 1
                }
                self.lastP += 2
            }
            //***********************************************************************************


            self.timeInSeconds = -Int(self.startDate.timeIntervalSinceNow)
            self.fileManager.closePrimesFileForAppend()
            self.pTable.removeAll()
            
        DispatchQueue.main.sync { [weak self] in
                guard let self = self else { return }
                self.lastLine.removeLast()
                let (newLastN, newLastP) = self.lastLine.parseLine()
                print( "findPrimes-  final lastN: \(newLastN)    lastP: \(newLastP)" )

                self.delegate.findPrimesCompleted(lastLine: self.lastLine)
            }
        }
    }
    
    //  a prime (p) is 'nice' if (p-1) / 2 is also prime
    func makeNicePrimesFile(nicePrimeURL: URL)    {
        print( "HLPrime-  makeNicePrimesFile" )
        self.nicePrimesFileURL = nicePrimeURL

        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }

            //*******     get last line in prime file to determine maxTestPrime needed in pTable      *********************
            self.fileManager.openPrimesFileForRead(with: self.primesFileURL.path)
            var line = self.fileManager.readPrimesFileLine()
            
            //  watch for present but empty file
            guard line != nil else {
                self.fileManager.closePrimesFileForRead()
                return
            }
            var previousline = line

            while line != nil {
                previousline = line
                line = self.fileManager.readPrimesFileLine()
            }
            self.fileManager.closePrimesFileForRead()

            (_, self.lastP) = previousline!.parseLine()
            let lastPrimeInPrimeFile = self.lastP
            //*************************************************************************************************************

            //  now we can create pTable and begin testing for 'nice' primes
            self.pTable = self.createPTable(maxPrime: self.lastP)

            self.startDate = Date()
            self.fileManager.openPrimesFileForRead(with: self.primesFileURL.path)
            self.fileManager.createNicePrimesFileForAppend(with: self.nicePrimesFileURL!.path)
        
            line = self.fileManager.readPrimesFileLine()    //  don't check prime '2' for niceness
            line = self.fileManager.readPrimesFileLine()    //  don't check prime '3' for niceness
            line = self.fileManager.readPrimesFileLine()    //  start at '5' which turns out to be nice as (5-1)/2 == 2

            guard line != nil else {
                 self.makeNicePrimesFileDidFinish()
                return
            }
            
            (_, self.lastP) = line!.parseLine()
        
            while self.lastP<=lastPrimeInPrimeFile && self.okToRun   {
                let possiblePrime = (self.lastP-1) / 2
             
                if self.isPrime(possiblePrime) {
                    self.fileManager.writeNicePrimesFile(line)
                    self.lastLine = line!
                }

                line = self.fileManager.readPrimesFileLine()
                guard line != nil else {
                     self.makeNicePrimesFileDidFinish()
                    return
                }
                
                (_, self.lastP) = line!.parseLine()
            }

            self.makeNicePrimesFileDidFinish()
        }
    }
    
    func makeNicePrimesFileDidFinish() {
        DispatchQueue.main.async {
            self.pTable.removeAll()
            self.fileManager.closeNicePrimesFileForAppend()
            self.fileManager.closePrimesFileForRead()

            self.timeInSeconds = -Int(self.startDate.timeIntervalSinceNow)
            self.delegate.findNicePrimesCompleted(lastLine: self.lastLine)
        }
    }

    func isPrime(_ value: HLPrimeType) -> Bool    {
        var candidateIsPrime = true
        let maxTestPrime = Int64(sqrt(Double(value)))
        
        //  when called from findPrimes() value will never be even
        //  when called from makeNicePrimesFile() value can be even
//        var index = 1   //  we don't try the value in [0] == 2
        var index = 0   //  we do try the value in [0] == 2
        
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

    public func createPTable(maxPrime: HLPrimeType) -> [HLPrimeType] {
        let maxPTablePrimeRequired = Int64(sqrt(Double(maxPrime)))
        var primeCandidate = pTable.last! + 2   //  start after the last known prime (3)
        let startDate = Date()

        while primeCandidate < maxPTablePrimeRequired {
            
                if isPrime(primeCandidate) {
                    pTable.append(primeCandidate)
                }
                primeCandidate += 2
        }

        print(String(format: "HLPrime-  createPTable completed in %0.2f seconds and has \(pTable.count) elements,  pTable last value: \(pTable[self.pTable.count - 1])", -Double(startDate.timeIntervalSinceNow)))
        return pTable
    }

    public init(primesFileURL: URL, delegate: HLPrimesProtocol) {
        print("HLPrime-  init: \(primesFileURL)")
        self.primesFileURL = primesFileURL
        self.delegate = delegate
    }
}