//
//  HLPrime.swift
//  Prime Finder
//
//  Created by Matthew Homer on 8/13/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

import Foundation

public typealias HLPrimeType = Int64

public class HLPrime {

    public static let HLPrimesURLKey     = "HLPrimesURLKey"
    public static let HLNicePrimesKey    = "HLNicePrimesKey"
    public static let HLTerminalPrimeKey = "HLTerminalPrimeKey"
    
    public static let HLParallelKey = "HLParallelKey"
    public static let HLProcessCountKey = "HLProcessCountKey"

    let fileManager = HLFileManager.shared

    var pTable: [HLPrimeType] = []
    internal var startDate: Date!    //  used to calculate timeInSeconds
    internal var stopDate: Date!    //  used to calculate timeInSeconds

    var lastN: Int = 2  //  output file already contains primes 2 and 3
    var lastP: HLPrimeType = 0
    var lastLine = ""
    var okToRun = true  //  used to exit big loop before app exits
    var processCount: Int


    public func findPrimes(primeURL: URL, maxPrime: HLPrimeType) async -> String {
        print( "\nHLPrime-  findPrimes-  maxPrime: \(maxPrime)" )
        
        let _ = fileManager.createTextFile(url: primeURL)
        let _ = fileManager.appendStringToFile("1\t2\n")

        okToRun = true //  must be above call to createPTable()
        pTable = self.createPTable(maxPrime: maxPrime)
        lastLine = "2\t3\n"
        (lastN, lastP) = lastLine.parseLine()   //  this is our starting point

        self.startDate = Date()  //  don't count the time to create pTable


        //***********************************************************************************
        while( maxPrime >= lastP && okToRun ) {
            if isPrime(lastP)    {
                lastLine = String(format: "%d\t%ld\n", lastN, lastP)
                fileManager.appendStringToFile(lastLine)
                lastN += 1
            }
            lastP += 2
        }
        //***********************************************************************************


        self.stopDate = Date()
        fileManager.closeFileForWritting()
        pTable.removeAll()
        return lastLine
    }
    
    //  a prime (p) is 'nice' if (p-1) / 2 is also prime
    func makeNicePrimesFile(primeURL: URL, nicePrimeURL: URL) async -> String {
        print( "HLPrime-  makeNicePrimesFile" )
        
            var nextLine = self.fileManager.getLastLine(primeURL)

            (self.lastN, self.lastP) = nextLine.parseLine()
            let lastPrimeInPrimeFile = self.lastP
            
            //  now we can create pTable and begin testing for 'nice' primes
            self.pTable = self.createPTable(maxPrime: self.lastP)
                
            self.startDate = Date()
            
            let success = self.fileManager.openFileForRead(url: primeURL)
            guard success else { return "" }
            
            let _ = self.fileManager.createTextFile(url: nicePrimeURL)

            nextLine = self.fileManager.getNextLine()  //  don't check prime '2' for niceness
            nextLine = self.fileManager.getNextLine()  //  don't check prime '3' for niceness

            self.okToRun = true
            
            while !nextLine.isEmpty && self.lastP<=lastPrimeInPrimeFile && self.okToRun   {
                let possiblePrime = (self.lastP-1) / 2
                
                if self.isPrime(possiblePrime) {
                    self.fileManager.appendStringToFile(nextLine)
                    self.lastLine = nextLine
                }
                
                nextLine = self.fileManager.getNextLine()
                if !nextLine.isEmpty {
                    (self.lastN, self.lastP) = nextLine.parseLine()
                }
            }
            
            self.stopDate = Date()
            self.pTable.removeAll()
            self.fileManager.closeFileForReading()
            self.fileManager.closeFileForWritting()
        return nextLine
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
    
    //  returns true if url found on the file system
/*    func isFileFound(url: URL?) -> Bool {
        guard url != nil else { return false }
        return fileManager.defaultFileManager.fileExists(atPath: url!.path)
    }*/
    
    public func createPTable(maxPrime: HLPrimeType) -> [HLPrimeType] {
        let maxPTablePrimeRequired = Int64(sqrt(Double(maxPrime)))
        pTable = [2, 3]
        var primeCandidate = pTable.last! + 2   //  start after the last known prime (3)
        let startDate = Date()

        while primeCandidate <= maxPTablePrimeRequired && okToRun {
            
                if isPrime(primeCandidate) {
                    pTable.append(primeCandidate)
                }
                primeCandidate += 2
        }

        self.stopDate = Date()
        print(String(format: "HLPrime-  createPTable completed in %0.2f seconds and has \(pTable.count) elements,  pTable last value: \(pTable[self.pTable.count - 1])", -Double(startDate.timeIntervalSinceNow)))
        return pTable
    }

    public init() {
        let numberOfCores = ProcessInfo().activeProcessorCount
        processCount = numberOfCores
        print("HLPrime-  init: numberOfCores: \(numberOfCores)")
    }
}
