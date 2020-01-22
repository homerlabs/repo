//
//  HLPrime+Extension.swift
//  Prime Finder
//
//  Created by Matthew Homer on 8/25/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

import Foundation

//typealias BatchFindPrimesCompletionClosure = () -> Void
//typealias PartialCompletionClosure = ([HLPrimeType]) -> Void

extension HLPrime {
    
    func getPrimes3(batchNumber: Int, maxPrime: HLPrimeType) {
        let primeBatchSize = maxPrime / (HLPrimeType(numberOfBatches) * 2)
        var primeCandidate = 3 + primeBatchSize * 2 * HLPrimeType(batchNumber)
        print( "getPrimes3-  batchNumber: \(batchNumber)  primeCandidate: \(primeCandidate)" )
        var lastLine = ""

        for _ in 0..<primeBatchSize {
            primeCandidate += 2
            
            if primeCandidate > maxPrime   { break }
            
            if isPrime(primeCandidate)    {
                lastLine = String(format: "%ld\n", primeCandidate)
                fileManagerPlus.appendLine(lastLine, fileId: Int32(batchNumber))
            }
        }
    }

    func findPrimes3(maxPrime: HLPrimeType, completion: @escaping (String) -> Void) {
        print( "\nHLPrime-  findPrimesMultithreaded3-  maxPrime: \(maxPrime)" )
        
        pTable = createPTable(maxPrime: maxPrime)
        (self.lastN, self.lastP) = (2, 3)   //  this is our starting point
        self.fileManagerPlus.createPrimesFilesForAppend(with: self.primesFileURL.path, numberOfFiles: 3)
    
//           print( "HLPrime-  findPrimes-  entering main loop ..." )
        self.startDate = Date()  //  don't count the time to create pTable
        
        let dispatchGroup = DispatchGroup()
        var blocks: [DispatchWorkItem] = []
        
        for batchNumber in 0..<numberOfBatches {
            dispatchGroup.enter()
            let block = DispatchWorkItem(flags: .inheritQoS) {
                self.getPrimes3(batchNumber: batchNumber, maxPrime: maxPrime)
                print("getPrimes completion block: \(batchNumber)")
                dispatchGroup.leave()
            }
            blocks.append(block)
            DispatchQueue.global().async(execute: block)
        }
        
        print("findPrimes3 completed")
        dispatchGroup.notify(queue: DispatchQueue.main) {
            self.timeInSeconds = -Int(self.startDate.timeIntervalSinceNow)
            self.fileManagerPlus.closePrimesFileForAppend()
            self.pTable.removeAll()
            let lastLine = String(format: "%d\t%ld", self.lastN, self.lastP)
            completion(lastLine)
        }
    }
    //  findPrimes3 stuff
    //***************************************************************************************************
    
    
    //  findPrimes2 stuff
    //***************************************************************************************************
    func findPrimes2(maxPrime: HLPrimeType, completion: @escaping (String) -> Void) {
        print( "\nHLPrime-  findPrimesMultithreaded2-  maxPrime: \(maxPrime)" )
        
        pTable = createPTable(maxPrime: maxPrime)
        (self.lastN, self.lastP) = (2, 3)   //  this is our starting point
        self.fileManager.createPrimesFileForAppend(with: self.primesFileURL.path)
    
//           print( "HLPrime-  findPrimes-  entering main loop ..." )
        self.startDate = Date()  //  don't count the time to create pTable
        
        let maxBatchNumber = Int(maxPrime) / (primeBatchSize * 2)   //  multiply by 2 because we imcrement by 2
        let dispatchGroup = DispatchGroup()
        var blocks: [DispatchWorkItem] = []
        
        for batchNumber in 0...maxBatchNumber {
            print( "findPrimes2-  starting batchNumber: \(batchNumber)" )
            
            dispatchGroup.enter()
            let block = DispatchWorkItem(qos: .userInitiated, flags: .barrier) {    //  need the .barrier flag to protect var waitingForBatchId
      //      let block = DispatchWorkItem(qos: .userInitiated) {    //  need the .barrier flag to protect var waitingForBatchId
                let result = self.getPrimes(batchNumber: batchNumber, maxPrime: maxPrime)
       //             print("getPrimes completion block: \(batchNumber)   holdingDict.count: \(self!.holdingDict.count)")
                
                //  even if result is empty we don't want a gap in batchNumbers
                self.holdingDict[batchNumber] = result
                self.drainHoldingDict()
                dispatchGroup.leave()
            }
            blocks.append(block)
            DispatchQueue.global().async(execute: block)
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            self.timeInSeconds = -Int(self.startDate.timeIntervalSinceNow)
            self.fileManager.closePrimesFileForAppend()
            self.pTable.removeAll()
            let lastLine = String(format: "%d\t%ld", self.lastN, self.lastP)
            completion(lastLine)
            print("inside completion block:  holdingDict.keys: \(self.holdingDict.keys)")
        }
    }
    
    func getPrimes(batchNumber: Int, maxPrime: HLPrimeType) -> [HLPrimeType] {
        var result: [HLPrimeType] = []
        var primeCandidate = HLPrimeType(batchNumber * self.primeBatchSize * 2 + 3)   //  we start with primes 2 and 3 already included
//      print( "batchNumber: \(batchNumber)  primeCandidate: \(primeCandidate)" )

        for _ in 0..<self.primeBatchSize {
            primeCandidate += 2
            if primeCandidate > maxPrime   { break }
            if self.isPrime(primeCandidate) { result.append(primeCandidate) }
        }
    
        return result
    }

    func drainHoldingDict() {
        print("drainHoldingDict-  batchId: \(waitingForBatchId)  holdingDict.keys: \(holdingDict.keys)")
        while let batchResult = holdingDict[waitingForBatchId] {
            var compoundLine = ""
            
            for item in batchResult {
                lastN += 1
                lastP = item
                let lastLine = String(format: "%d\t%ld\n", self.lastN, item)
                compoundLine.append(lastLine)
            }
            
            //  often, compoundLine will be "" on the last batch
            fileManager.appendPrimesLine(compoundLine)

            holdingDict.removeValue(forKey: waitingForBatchId)
            waitingForBatchId += 1
        }
    }
}
