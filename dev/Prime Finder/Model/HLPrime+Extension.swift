//
//  HLPrime.swift
//  Prime Finder
//
//  Created by Matthew Homer on 8/13/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

import Foundation

extension HLPrime {
        
    func getPrimes(startNumber: HLPrimeType, batchSize: HLPrimeType, maxPrime: HLPrimeType) -> [HLPrimeType] {
        var result: [HLPrimeType] = []
        var primeCandidate = startNumber
        let lastPrime = min(primeCandidate+batchSize, maxPrime)
        print( "getPrimes startNumber: \(startNumber)  lastPrime: \(lastPrime)" )

        while primeCandidate <= lastPrime-2 && okToRun {
            primeCandidate += 2
            
            if isPrime(primeCandidate) {
                result.append(primeCandidate)
            }
        }
        return result
    }
    
    func getBatchSize(processCount: Int, maxPrime: HLPrimeType) -> Int {
        var batchSize = Int(maxPrime) / processCount + 1
        if batchSize % 2 == 1 {
            batchSize += 1
        }
        
        return batchSize
    }
    
 //  uses DispatchQueue with maxConcurrentOperationCount set to processInfo.activeProcessorCount
 //  uses holdingDict to sync operation outputs
 func findPrimes(primeURL: URL, maxPrime: HLPrimeType, processCount: Int) async -> [HLPrimeType] {
     print( "\nHLPrimeParallel-  findPrimes-  maxPrime: \(maxPrime)" )
     
     let batchSize = getBatchSize(processCount: processCount, maxPrime: maxPrime)
//     print( "\nHLPrime-  findPrimes-  primesFileURL: \(String(describing: primesFileURL))   appendSuccess: \(appendSuccess)" )

     okToRun = true //  must be above call to createPTable()
     pTable = createPTable(maxPrime: maxPrime)
     lastLine = "2\t3\n"
     (lastN, lastP) = lastLine.parseLine()   //  this is our starting point
         
     startDate = Date()  //  don't count the time to create pTable
     
     async let result0 = getPrimes(startNumber: HLPrimeType(batchSize * 0 + 3), batchSize: HLPrimeType(batchSize), maxPrime: maxPrime)
     async let result1 = getPrimes(startNumber: HLPrimeType(batchSize * 1 + 3), batchSize: HLPrimeType(batchSize), maxPrime: maxPrime)
     async let result2 = getPrimes(startNumber: HLPrimeType(batchSize * 2 + 3), batchSize: HLPrimeType(batchSize), maxPrime: maxPrime)
     async let result3 = getPrimes(startNumber: HLPrimeType(batchSize * 3 + 3), batchSize: HLPrimeType(batchSize), maxPrime: maxPrime)

     async let result4 = getPrimes(startNumber: HLPrimeType(batchSize * 4 + 3), batchSize: HLPrimeType(batchSize), maxPrime: maxPrime)
     async let result5 = getPrimes(startNumber: HLPrimeType(batchSize * 5 + 3), batchSize: HLPrimeType(batchSize), maxPrime: maxPrime)
     async let result6 = getPrimes(startNumber: HLPrimeType(batchSize * 6 + 3), batchSize: HLPrimeType(batchSize), maxPrime: maxPrime)
     async let result7 = getPrimes(startNumber: HLPrimeType(batchSize * 7 + 3), batchSize: HLPrimeType(batchSize), maxPrime: maxPrime)

     let result = await result0 + result1 + result2 + result3 + result4 + result5 + result6 + result7
//     print("result \(result)")


     let _ = fileManager.createTextFile(url: primeURL)
     primesToDisk(isNumbered: true, primes: result)
     fileManager.closeFileForWritting()
     pTable.removeAll()

     stopDate = Date()
     return result
 }

    func primesToDisk(isNumbered: Bool, primes: [HLPrimeType]) {
        var outputLine = ""
        
        if isNumbered {
            outputLine = "1\t2\n2\t3\n"
        }
        else {
            outputLine = "2\t3\t"
        }
        
        let _ = fileManager.appendStringToFile(outputLine)
        var lastN: Int = 2
        
        for prime in primes {
            lastN += 1

            if isNumbered {
                lastLine = String(format: "%d\t%ld\n", lastN, prime)
            }
            else {
                lastLine = String(format: "%ld\t", prime)
            }
            
     //       print("lastLine \(lastLine)")
            fileManager.appendStringToFile(lastLine)
        }
    }

    //  used to verify no out of order results
    //  return not valid if next count is not one more than last count and
    //  return not valid if next prime is <= last prime
    func primeFileIsValid(primeFileURL: URL?) -> Bool {
        var returnValue = true
        if let url = primeFileURL {
            let success = self.fileManager.openFileForRead(url: url)
            guard success else { return false }

            var line = self.fileManager.getNextLine()
            var currentCount = 0
            var currentPrime: HLPrimeType = 0
            
            var previousCount = 1
            var previousPrime: HLPrimeType = 2

            if !line.isEmpty  {
                (currentCount, currentPrime) = line.parseLine()
            }
            
            while !line.isEmpty    {
                line = self.fileManager.getNextLine()
                if !line.isEmpty {
                    (currentCount, currentPrime) = line.parseLine()
                    
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
        }
        
        return returnValue
    }

    //  returns batchSize rounding up and making sure the value is even
    //  batchSize needs to be even because its multipled to determine startPrimeCandidate
    func batchSize(maxPrime: HLPrimeType) -> HLPrimeType {
        var batchSize = (maxPrime / HLPrimeType(processCount)) + 1
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
    
}
