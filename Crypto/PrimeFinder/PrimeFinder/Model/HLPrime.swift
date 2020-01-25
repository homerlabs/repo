//
//  HLPrime.swift
//  Prime Finder
//
//  Created by Matthew Homer on 8/13/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

import Foundation

public typealias HLPrimeType = Int64

public typealias HLCompletionClosure = (String) -> Void

public class HLPrime {

    public static let PrimesBookmarkKey       = "HLPrimesBookmarkKey"
    public static let NicePrimesBookmarkKey   = "HLNicePrimesBookmarkKey"

    let primesFileURL: URL  //  set during init()
    var nicePrimesFileURL: URL?
    let fileManager: HLFileManager = HLFileManager.sharedInstance()

    var pTable: [HLPrimeType] = [2, 3]  //  starts out with the first 2 primes, used to find / validate primes
    var startDate: Date!    //  used to calculate timeInSeconds
    var timeInSeconds = 0   //  time for makePrimes, factorPrimes, or loadBuf to run

    var lastN: Int = 0
    var lastP: HLPrimeType = 0
    var lastLine = ""
    var okToRun = true  //  used to exit big loop before app exits

    //**********************************************************************************************
    //  these are used in findPrimesMultithreaded()
    
    //  used in findPrimes2
    let primeBatchSize = 50000
        
    //  used in findPrimes3
    let batchCount = 10

    var holdingDict: [Int:[HLPrimeType]] = [:]    //  needs to be protected for multithread
    var waitingForBatchId = 0                       //  needs to be protected for multithread

    let queue0 = DispatchQueue(label: "PrimeFinderQueue0")
    let queue1 = DispatchQueue(label: "PrimeFinderQueue1")
    let queue2 = DispatchQueue(label: "PrimeFinderQueue2")
    let queue3 = DispatchQueue(label: "PrimeFinderQueue3")
    let queue4 = DispatchQueue(label: "PrimeFinderQueue4")
    let dispatchGroup = DispatchGroup()
    let fileManager2 = FileManager.default
    var writeFileHandle: FileHandle?


    public func findPrimes(maxPrime: HLPrimeType, completion: @escaping HLCompletionClosure) {
        print( "\nHLPrime-  findPrimes-  maxPrime: \(maxPrime)" )

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            self.pTable = self.createPTable(maxPrime: maxPrime)
            (self.lastN, self.lastP) = (3, 5)   //  this is our starting point
            
            let error = self.fileManager.createPrimesFileForAppend(with: self.primesFileURL.path)
            assert(error==0, "createPrimesFileForAppend failed with error: \(error)")
            
            self.lastLine = "2\t3\n"
        
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
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let (newLastN, newLastP) = self.lastLine.parseLine()
                print( "findPrimes-  final lastN: \(newLastN)    lastP: \(newLastP)" )
                completion(self.lastLine)
            }
        }
    }
    
    //  a prime (p) is 'nice' if (p-1) / 2 is also prime
    func makeNicePrimesFile(nicePrimeURL: URL, completion: @escaping HLCompletionClosure)    {
        print( "HLPrime-  makeNicePrimesFile" )
        self.nicePrimesFileURL = nicePrimeURL

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            //*******     get last line in prime file to determine maxTestPrime needed in pTable      *********************
            self.fileManager.openPrimesFileForRead(with: self.primesFileURL.path)
            var line = self.fileManager.readPrimesFileLine()
            var previousline = line
            
            if line != nil {    //  have to protect against missing prime file
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
                
                if line != nil  {
                    (_, self.lastP) = line!.parseLine()
                }
                
                while line != nil && self.lastP<=lastPrimeInPrimeFile && self.okToRun   {
                    let possiblePrime = (self.lastP-1) / 2
                    
                    if self.isPrime(possiblePrime) {
                        self.fileManager.writeNicePrimesFile(line)
                        self.lastLine = line!
                    }
                    
                    line = self.fileManager.readPrimesFileLine()
                    if line != nil {
                        (_, self.lastP) = line!.parseLine()
                    }
                }
                
                self.timeInSeconds = -Int(self.startDate.timeIntervalSinceNow)
            }

            self.pTable.removeAll()
            self.fileManager.closeNicePrimesFileForAppend()
            self.fileManager.closePrimesFileForRead()
            
            DispatchQueue.main.async {
          //      print( "DispatchQueue.main.async" )
                completion(self.lastLine)

            }
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
    
    //  return not valid if next count is not one more than last count and
    //  return not valid if next prime is <= last prime
    func primeFileIsValid() -> Bool {
        var returnValue = true
        fileManager.openPrimesFileForRead(with: primesFileURL.path)
        var line = fileManager.readPrimesFileLine()
        var currentCount = 0
        var currentPrime: HLPrimeType = 0
        
        var previousCount = 1
        var previousPrime: HLPrimeType = 2

        if line != nil  {
            (currentCount, currentPrime) = line!.parseLine()
        }
        
        while line != nil    {
            line = self.fileManager.readPrimesFileLine()
            if line != nil {
                (currentCount, currentPrime) = line!.parseLine()
                
                if currentCount != previousCount+1 {
                    returnValue = false
                    print("FAILED:  currentCount != previousCount+1: \(currentCount) != \( previousCount+1)")
                    break
                }
                if previousPrime >= currentPrime {
                    returnValue = false
                    print("FAILED:  previousPrime >= currentPrime: \(previousPrime) >= \( currentPrime)")
                    break
                }
                previousPrime = currentPrime
                previousCount = currentCount
            }
        }
        return returnValue
    }

    public func createPTable(maxPrime: HLPrimeType) -> [HLPrimeType] {
        let maxPTablePrimeRequired = Int64(sqrt(Double(maxPrime)))
        var primeCandidate = pTable.last! + 2   //  start after the last known prime (3)
        let startDate = Date()

        while primeCandidate <= maxPTablePrimeRequired {
            
                if isPrime(primeCandidate) {
                    pTable.append(primeCandidate)
                }
                primeCandidate += 2
        }

        print(String(format: "HLPrime-  createPTable completed in %0.2f seconds and has \(pTable.count) elements,  pTable last value: \(pTable[self.pTable.count - 1])", -Double(startDate.timeIntervalSinceNow)))
        return pTable
    }

    public init(primesFileURL: URL) {
        print("HLPrime-  init: \(primesFileURL)")
        self.primesFileURL = primesFileURL
    }
}
