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
    
    func findPrimes3(maxPrime: HLPrimeType, completion: @escaping (String) -> Void) {
        print( "\nHLPrime-  findPrimesMultithreaded3-  maxPrime: \(maxPrime)" )
        
        pTable = createPTable(maxPrime: maxPrime)
        (self.lastN, self.lastP) = (2, 3)   //  this is our starting point
        self.fileManager.createPrimesFileForAppend(with: self.primesFileURL.path)
    
//           print( "HLPrime-  findPrimes-  entering main loop ..." )
        self.startDate = Date()  //  don't count the time to create pTable
        
        let numberOfBatches = 2
        let dispatchGroup = DispatchGroup()
        var blocks: [DispatchWorkItem] = []
        
        for batchNumber in 0..<numberOfBatches {
            dispatchGroup.enter()
            let block = DispatchWorkItem(flags: .inheritQoS) {
                self.getPrimes(batchNumber: batchNumber, maxPrime: maxPrime) { [weak self] result in
       //             print("getPrimes completion block: \(batchNumber)   holdingDict.count: \(self!.holdingDict.count)")
                    
                    self?.holdingDict[batchNumber] = result
                    self?.drainHoldingDict()
                    dispatchGroup.leave()
                }
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
        }
    }
    
    func findPrimes2(maxPrime: HLPrimeType, completion: @escaping (String) -> Void) {
        print( "\nHLPrime-  findPrimesMultithreaded2-  maxPrime: \(maxPrime)" )
        
        pTable = createPTable(maxPrime: maxPrime)
        (self.lastN, self.lastP) = (2, 3)   //  this is our starting point
        self.fileManager.createPrimesFileForAppend(with: self.primesFileURL.path)
    
//           print( "HLPrime-  findPrimes-  entering main loop ..." )
        self.startDate = Date()  //  don't count the time to create pTable
        
        let maxBatchNumber = Int(maxPrime) / (primeBatchSize * 2)   //  always add 2 for next find prime itereation
        let dispatchGroup = DispatchGroup()
        var blocks: [DispatchWorkItem] = []
        
        for batchNumber in 0...maxBatchNumber {
            dispatchGroup.enter()
            let block = DispatchWorkItem(flags: .inheritQoS) {
                self.getPrimes(batchNumber: batchNumber, maxPrime: maxPrime) { [weak self] result in
       //             print("getPrimes completion block: \(batchNumber)   holdingDict.count: \(self!.holdingDict.count)")
                    
                    self?.holdingDict[batchNumber] = result
                    self?.drainHoldingDict()
                    dispatchGroup.leave()
                }
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
        }
    }
    
    func getPrimes(batchNumber: Int, maxPrime: HLPrimeType, withCompletion completion: (([HLPrimeType]) -> Void)?) {
        DispatchQueue.global(qos: .userInitiated ).async {

            var result: [HLPrimeType] = []
            var primeCandidate = HLPrimeType(batchNumber * self.primeBatchSize * 2 + 3)   //  we start with primes 2 and 3 already included
 //      print( "batchNumber: \(batchNumber)  primeCandidate: \(primeCandidate)" )

            for _ in 0..<self.primeBatchSize {
                primeCandidate += 2
                
                if primeCandidate > maxPrime   { break }
                
                if self.isPrime(primeCandidate) { result.append(primeCandidate) }
            }
            
            DispatchQueue.main.async {
                completion?(result)
            }
        }
    }

    func drainHoldingDict() {
        while let batchResult = holdingDict[waitingForBatchId] {
            var compoundLine = ""
            var lastLine = "\n"
            for item in batchResult {
                lastN += 1
                lastP = item
                lastLine = String(format: "%d\t%ld\n", self.lastN, item)
                compoundLine.append(lastLine)
            }
            if lastLine.count > 1 {
                fileManager.appendPrimesLine(compoundLine)
            }

            holdingDict.removeValue(forKey: waitingForBatchId)
    //        print("drainHoldingDict-  drainingBatchId: \(waitingForBatchId)  lastLine: '\(lastLine.removeLast())'  holdingDict.count: \(holdingDict.count)")
            waitingForBatchId += 1
        }
    }
}
