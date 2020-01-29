//
//  HLPrime+Extension.swift
//  Prime Finder
//
//  Created by Matthew Homer on 8/25/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

import Foundation

extension HLPrime {
    
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

          pTable = createPTable(maxPrime: maxPrime)
          (self.lastN, self.lastP) = (2, 3)   //  this is our starting point
          fileManager.createPrimesFileForAppend(with: primesFileURL.path)
          fileManager.closePrimesFileForAppend()

          writeFileHandle = FileHandle(forWritingAtPath: primesFileURL.path)
          writeFileHandle?.seekToEndOfFile()

          self.startDate = Date()  //  don't count the time to create pTable
          var operations: [Operation] = []

          for batchNumber in 0..<batchCount {
              let task = {
                  let result = self.getPrimes(batchNumber: batchNumber, maxPrime: maxPrime)
          //        print( "findPrimes0-  finished batchNumber: \(batchNumber) result.count: \(result.count)" )

                  self.queue0.sync {
                      self.holdingDict[batchNumber] = result
             //         print("drainHoldingDict-  waitingForBatchId: \(self.waitingForBatchId)    batchId: \(batchNumber)   result.count: \(result.count)    holdingDict.keys: \(self.holdingDict.keys)")
                      self.drainHoldingDict()
                  }
               }
              
              let block = BlockOperation(block: task)
         //     dependentBlock.addDependency(block, block)
              operations.append(block)
          }
          
          findPrimesQueue.addOperations(operations, waitUntilFinished: true)

          print("Inside completion code:    holdingDict.keys: \(self.holdingDict.keys)")
          self.timeInSeconds = -Int(self.startDate.timeIntervalSinceNow)

          //          self.fileManager.closePrimesFileForAppend()
          self.writeFileHandle?.closeFile()

          self.pTable.removeAll()
          self.lastLine = String(format: "%d\t%ld", self.lastN, self.lastP)
   
          DispatchQueue.main.async { [weak self] in
              guard let self = self else { return }
              let (newLastN, newLastP) = self.lastLine.parseLine()
              print( "findPrimes-  final lastN: \(newLastN)    lastP: \(newLastP)" )
              completion(self.lastLine)
          }
      }
    
    //  findPrimes2 stuff
    //***************************************************************************************************
    func findPrimes2(maxPrime: HLPrimeType, completion: @escaping (String) -> Void) {
        print( "\nHLPrime-  findPrimesMultithreaded2-  maxPrime: \(maxPrime)" )
        
        pTable = createPTable(maxPrime: maxPrime)
        (self.lastN, self.lastP) = (2, 3)   //  this is our starting point
        self.fileManager.createPrimesFileForAppend(with: self.primesFileURL.path)
    
//           print( "HLPrime-  findPrimes-  entering main loop ..." )
        self.startDate = Date()  //  don't count the time to create pTable
        
        let maxBatchNumber = Int(maxPrime / HLPrimeType((primeBatchSize * 2)))   //  multiply by 2 because we increment by 2
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

    func drainHoldingDict() {
        while let batchResult = holdingDict[waitingForBatchId] {
            var compoundLine = ""
            var lastLine = ""

            for item in batchResult {
                lastN += 1
                lastP = item
                lastLine = String(format: "%d\t%ld\n", lastN, lastP)
                compoundLine.append(lastLine)
            }

            //  often, compoundLine will be "" on the last batch
      //      fileManager.appendPrimesLine(compoundLine)    //  old way
            if let data = compoundLine.data(using: .utf8) {
                writeFileHandle?.write(data)
            }
            
 //           print("waitingForBatchId: \(waitingForBatchId)    lastLine: \(lastLine)")
            holdingDict.removeValue(forKey: waitingForBatchId)
            waitingForBatchId += 1
        }
    }
}
