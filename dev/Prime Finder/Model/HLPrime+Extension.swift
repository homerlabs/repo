//
//  HLPrime+Extension.swift
//  Prime Finder
//
//  Created by Matthew Homer on 8/25/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

import Foundation

extension HLPrime {

    func findPrimesSetup(maxPrime: HLPrimeType) {
        pTable = createPTable(maxPrime: maxPrime)
        (self.lastN, self.lastP) = (2, 3)   //  this is our starting point
        
        if let primeURL = primesFileURL {
            fileManager.createPrimesFileForAppend(with: primeURL.path)
            fileManager.closePrimesFileForAppend()

            writeFileHandle = FileHandle(forWritingAtPath: primeURL.path)
            writeFileHandle?.seekToEndOfFile()
        }

        self.startDate = Date()  //  don't count the time to create pTable
    }
    
    func findPrimesCompletion(completion: @escaping (String) -> Void) {
        timeInSeconds = -Int(startDate.timeIntervalSinceNow)
        pTable.removeAll()
        writeFileHandle?.closeFile()
        print( "findPrimes-  final lastN: \(lastN)    lastP: \(lastP)" )
        lastLine = String(format: "%d\t%ld", self.lastN, lastP)
        
        if !primeFileIsValid() {
            print("    *********  findPrimes completed but primeFileIsValid() failed!!       ********* \n")
        }

        completion(lastLine)
    }
    
    //  uses DispatchQueue with maxConcurrentOperationCount set to processInfo.activeProcessorCount
    //  uses holdingDict to sync operation outputs
    func findPrimes3(maxPrime: HLPrimeType, completion: @escaping (String) -> Void) {
        print( "\nHLPrime-  findPrimes3-  maxPrime: \(maxPrime)" )
        let dispatchQueue = DispatchQueue.init(label: "FindPrimes0Queue", qos: .userInteractive, attributes: [], autoreleaseFrequency: .workItem, target: DispatchQueue.global(qos: .userInteractive))
        dispatchQueue.async {
            self.findPrimesBlocking(maxPrime: maxPrime, completion: completion)
        }
    }

    func findPrimesBlocking(maxPrime: HLPrimeType, completion: @escaping (String) -> Void) {
        //       print( "batchSize(maxPrime: maxPrime): \(batchSize(maxPrime: maxPrime))" )

        var operations: [Operation] = []
        findPrimesSetup(maxPrime: maxPrime)
        
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
            self?.findPrimesCompletion(completion: completion)
        }
    }
    
    //  findPrimes2 stuff
    //  uses batchCount to make DispacthWorkItems then added to a DispatchGroup
    //  uses holdingDict to sync operation outputs
    //***************************************************************************************************
    func findPrimes2(maxPrime: HLPrimeType, completion: @escaping (String) -> Void) {
        print( "\nHLPrime-  findPrimesMultithreaded2-  maxPrime: \(maxPrime)" )
        
        findPrimesSetup(maxPrime: maxPrime)

        let dispatchGroup = DispatchGroup()
        var blocks: [DispatchWorkItem] = []
        
        for batchNumber in 0..<batchCount {
     //       print( "findPrimes2-  starting batchNumber: \(batchNumber)" )
            
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
            self.findPrimesCompletion(completion: completion)
        }
    }
    
    //  returns batchSize rounding up and making sure the value is even
    //  batchSize needs to be even because its multipled to determine startPrimeCandidate
    func batchSize(maxPrime: HLPrimeType) -> HLPrimeType {
        var batchSize = (maxPrime / HLPrimeType(batchCount)) + 1
        if batchSize % HLPrimeType(2) == 1 {
            batchSize += 1
        }
        return batchSize
    }
    
    func getPrimes(batchNumber: Int, maxPrime: HLPrimeType) -> [HLPrimeType] {
        let batchSize = self.batchSize(maxPrime: maxPrime)
        var result: [HLPrimeType] = []
        var primeCandidate = HLPrimeType(batchNumber) * batchSize + 5   //  we start with primes 2 and 3 already included
        let lastPrime = min(primeCandidate+batchSize, maxPrime) - 2
 //       print( "getPrimes batchNumber: \(batchNumber)   primeCandidate: \(primeCandidate+2)" )

        while primeCandidate <= lastPrime && okToRun {
            primeCandidate += 2
            if isPrime(primeCandidate) { result.append(primeCandidate) }
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
