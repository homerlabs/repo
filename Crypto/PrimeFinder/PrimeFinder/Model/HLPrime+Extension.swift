//
//  HLPrime+Extension.swift
//  Prime Finder
//
//  Created by Matthew Homer on 8/25/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

import Foundation

extension HLPrime {

    func fpSetup(maxPrime: HLPrimeType) {
        pTable = createPTable(maxPrime: maxPrime)
        (self.lastN, self.lastP) = (2, 3)   //  this is our starting point
        fileManager.createPrimesFileForAppend(with: primesFileURL.path)
        fileManager.closePrimesFileForAppend()

        writeFileHandle = FileHandle(forWritingAtPath: primesFileURL.path)
        writeFileHandle?.seekToEndOfFile()

        self.startDate = Date()  //  don't count the time to create pTable
    }
    
    func fpCompletion(completion: @escaping (String) -> Void) {
        timeInSeconds = -Int(startDate.timeIntervalSinceNow)
        pTable.removeAll()
        writeFileHandle?.closeFile()
        print( "findPrimes-  final lastN: \(lastN)    lastP: \(lastP)" )
        lastLine = String(format: "%d\t%ld", self.lastN, lastP)
        completion(lastLine)
    }
    
    func findPrimes3(maxPrime: HLPrimeType, completion: @escaping (String) -> Void) {
        print( "\nHLPrime-  findPrimes3-  maxPrime: \(maxPrime)" )
        let dispatchQueue = DispatchQueue.init(label: "FindPrimes0Queue", qos: .userInteractive, attributes: [], autoreleaseFrequency: .workItem, target: DispatchQueue.global(qos: .userInteractive))
        dispatchQueue.async {
            self.findPrimesBlocking(maxPrime: maxPrime, completion: completion)
        }
    }

    func getBatchRanges(maxPrime: HLPrimeType) {
        let batchSize = self.batchSize(maxPrime: maxPrime)
        for batchNumber in 0..<HLPrimeType(batchCount) {
        let startRange = batchNumber * batchSize
        print( "getBatchRanges-  batchNumber: \(batchNumber)    startRange: \(startRange)" )
        }
    }

    func findPrimesBlocking(maxPrime: HLPrimeType, completion: @escaping (String) -> Void) {
        //       print( "batchSize(maxPrime: maxPrime): \(batchSize(maxPrime: maxPrime))" )

        var operations: [Operation] = []
        fpSetup(maxPrime: maxPrime)
        
        for batchNumber in 0..<batchCount {
            let task = {
                let result = self.getPrimes(batchNumber: batchNumber, maxPrime: maxPrime)
                //        print( "findPrimes0-  finished batchNumber: \(batchNumber) result.count: \(result.count)" )
                self.drainHoldingDict(batchId: batchNumber, data: result)
            }

            let block = BlockOperation(block: task)
            //     dependentBlock.addDependency(block, block)
                operations.append(block)
            }

        operationsQueue.addOperations(operations, waitUntilFinished: true)
        DispatchQueue.main.async { [weak self] in
            self?.fpCompletion(completion: completion)
        }
    }
    
    //  findPrimes2 stuff
    //***************************************************************************************************
    func findPrimes2(maxPrime: HLPrimeType, completion: @escaping (String) -> Void) {
        print( "\nHLPrime-  findPrimesMultithreaded2-  maxPrime: \(maxPrime)" )
        
        let maxBatchNumber = Int(maxPrime / HLPrimeType((primeBatchSize * 2)))   //  multiply by 2 because we increment by 2
        let dispatchGroup = DispatchGroup()
        var blocks: [DispatchWorkItem] = []
        
        fpSetup(maxPrime: maxPrime)

        for batchNumber in 0..<maxBatchNumber {
            print( "findPrimes2-  starting batchNumber: \(batchNumber)" )
            
            dispatchGroup.enter()
     //       let block = DispatchWorkItem(qos: .userInteractive, flags: .barrier) {    //  need the .barrier flag to protect var waitingForBatchId
            let block = DispatchWorkItem(qos: .userInteractive) {    //  need the .barrier flag to protect var waitingForBatchId
                let result = self.getPrimes(batchNumber: batchNumber, maxPrime: maxPrime)
                //print("getPrimes completion block: \(batchNumber)   result: \(result.count)")
                
                //  this makes sync call to queue0 (sequential queue)
                self.drainHoldingDict(batchId: batchNumber, data: result)
                
                dispatchGroup.leave()
            }
            blocks.append(block)
            DispatchQueue.global().async(execute: block)
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            self.fpCompletion(completion: completion)
        }
    }
    
    func batchSize(maxPrime: HLPrimeType) -> HLPrimeType {
        let roundOff: HLPrimeType = 10
        var size = maxPrime / HLPrimeType(batchCount)
        size /= roundOff
        size *= roundOff
        return size
    }

    func getPrimes(batchNumber: Int, maxPrime: HLPrimeType) -> [HLPrimeType] {
        var result: [HLPrimeType] = []
        let batchSize = self.batchSize(maxPrime: maxPrime)
        var primeCandidate = HLPrimeType(batchNumber) * batchSize + 5   //  we start with primes 2 and 3 already included
        let lastPrime = min(primeCandidate+batchSize, maxPrime)
 //       print( "getPrimes batchNumber: \(batchNumber)   primeCandidate: \(primeCandidate+2)" )

        while primeCandidate < lastPrime {
            if isPrime(primeCandidate) { result.append(primeCandidate) }
            primeCandidate += 2
        }

        return result
    }

    func drainHoldingDict(batchId: Int, data: [HLPrimeType]) {
        queue0.sync {
            holdingDict[batchId] = data
            
            while let batchResult = holdingDict[waitingForBatchId] {
                var compoundLine = ""
                var lastLine = ""

                for item in batchResult {
                    lastN += 1
                    lastP = item
                    lastLine = String(format: "%d\t%ld\n", lastN, lastP)
                    compoundLine.append(lastLine)
                }

                //  compoundLine might be "" on the last batch
                if let data = compoundLine.data(using: .utf8) {
                    writeFileHandle?.write(data)
                }
                
                holdingDict.removeValue(forKey: waitingForBatchId)
                waitingForBatchId += 1
            }
        }
    }
}
