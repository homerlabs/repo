//
//  HLPrime+Extension.swift
//  Prime Finder
//
//  Created by Matthew Homer on 8/25/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

import Foundation

extension HLPrime {
    
       func findPrimes3(maxPrime: HLPrimeType, completion: @escaping (String) -> Void)  {
           print( "\nHLPrime-  findPrimesMultithreaded2-  maxPrime: \(maxPrime)" )
           
           pTable = createPTable(maxPrime: maxPrime)
           (self.lastN, self.lastP) = (2, 3)   //  this is our starting point
           fileManager.createPrimesFileForAppend(with: primesFileURL.path)
           fileManager.closePrimesFileForAppend()
           var batchStartingIndex = 2
           
           writeFileHandle = FileHandle(forWritingAtPath: primesFileURL.path)
           writeFileHandle?.seekToEndOfFile()

           var blocks: [DispatchWorkItem] = []
           let batchSize = maxPrime / HLPrimeType(batchCount) / 2
           print( "HLPrime-  findPrimesMultithreaded2-  batchSize: \(batchSize)" )

           startDate = Date()  //  don't count the time to create pTable

           for batchNumber in 0..<batchCount {
               print( "findPrimes2-  starting batchNumber: \(batchNumber)   batchCount: \(batchCount)" )
               
               dispatchGroup.enter()
               let block = DispatchWorkItem(qos: .userInitiated, flags: .barrier, block: {
                   let result = self.getPrimes(batchNumber: batchNumber, maxPrime: maxPrime)
                   //  updating holdingDict in sequential queue
                   self.queue0.sync {
                       self.updateHoldingDictWith(batchId: batchNumber, startingIndex: batchStartingIndex, result: result)
                       batchStartingIndex += result.count
                   }
                   self.dispatchGroup.leave()
               })

               blocks.append(block)
               if batchNumber % 4 == 0 {
                   queue1.async(execute: block)
               }
               else if batchNumber % 4 == 1 {
                   queue2.async(execute: block)
               }
               else if batchNumber % 4 == 2 {
                   queue3.async(execute: block)
               }
               else if batchNumber % 4 == 3 {
                   queue4.async(execute: block)
               }
           }

           dispatchGroup.notify(queue: DispatchQueue.main) {
               print("Inside completion code:    holdingDict.keys: \(self.holdingDict.keys)")
               self.timeInSeconds = -Int(self.startDate.timeIntervalSinceNow)
    
     //          self.fileManager.closePrimesFileForAppend()
               self.writeFileHandle?.closeFile()
               
               self.pTable.removeAll()
               let lastLine = String(format: "%d\t%ld", self.lastN, self.lastP)
               completion(lastLine)
           }
       }
       
    //  findPrimes3 stuff
    //***************************************************************************************************
    
    func batchSize(maxPrime: HLPrimeType) -> HLPrimeType {
        let roundOff: HLPrimeType = 10
        var size = maxPrime / HLPrimeType(batchCount)
        size /= roundOff
        size *= roundOff
        return size
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
        
        let maxBatchNumber = Int(maxPrime / HLPrimeType((primeBatchSize * 2)))   //  multiply by 2 because we imcrement by 2
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
    
    //  used in findPrimes3
    func getPrimes(batchNumber: Int, maxPrime: HLPrimeType) -> [HLPrimeType] {
        var result: [HLPrimeType] = []
        let batchSize3 = batchSize(maxPrime: maxPrime)
        var primeCandidate = HLPrimeType(batchNumber) * batchSize3 * 2 + 3   //  we start with primes 2 and 3 already included
    //        print( "getPrimes batchNumber: \(batchNumber)   primeCandidate: \(primeCandidate+2)" )

        for _ in 0..<batchSize3 {
            primeCandidate += 2
            if primeCandidate > maxPrime   { break }
            if isPrime(primeCandidate) { result.append(primeCandidate) }
        }

        return result
    }

    //  used in findPrimes2
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

    //  used in findPrimes3
    func updateHoldingDictWith(batchId: Int, startingIndex: Int, result: [HLPrimeType]) {
        holdingDict[batchId] = result
        print("updateHoldingDictWith-  batchId: \(batchId)  startingIndex: \(startingIndex)  holdingDict.keys: \(holdingDict.keys)")

        while let batchResult = holdingDict[waitingForBatchId] {
          var compoundLine = ""
          var lastLine = ""
          var index = startingIndex

          for item in batchResult {
              index += 1
        //            lastP = item
              lastLine = String(format: "%d\t%ld\n", index, item)
              compoundLine.append(lastLine)
          }
          
          if let data = compoundLine.data(using: .utf8)
           {
              writeFileHandle?.seekToEndOfFile()
              writeFileHandle?.write(data)
          }
          
          //  sometimes, compoundLine will be "" on the last batch
        //          fileManager.appendPrimesLine(compoundLine)

          let x = holdingDict.removeValue(forKey: waitingForBatchId)
        //          print("drained-  waitingForBatchId: \(waitingForBatchId)  lastLine: \(lastLine)")
          if x == nil {
              print("**************************** updateHoldingDictWith-  drainingBatchId: \(waitingForBatchId) returned nil.\n")
          }
          else if x!.count == 0 {
              print("**************************** updateHoldingDictWith-  drainingBatchId: \(waitingForBatchId) returned empty.\n")
          }
          waitingForBatchId += 1
        }
    }
}
