//
//  HLPrime.swift
//  Prime Finder
//
//  Created by Matthew Homer on 8/13/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

import Foundation

//public typealias HLPrimeType = Int64

//public typealias HLCompletionClosure = (String) -> Void

public class HLPrimeParallel {

    public static let HLPrimesURLKey     = "HLPrimesURLKey"
    public static let HLNicePrimesKey    = "HLNicePrimesKey"
    public static let HLTerminalPrimeKey = "HLTerminalPrimeKey"
    public static let HLNumberOfProcessesKey = "HLNumberOfProcessesKey"

    let fileManager = HLFileManager.shared

    var pTable: [HLPrimeType] = []
    var startDate: Date!    //  used to calculate timeInSeconds
    var timeInSeconds = 0   //  time for makePrimes, factorPrimes, or loadBuf to run

    var lastN: Int = 2  //  output file already contains primes 2 and 3
    var lastP: HLPrimeType = 0
    var lastLine = ""
    var okToRun = true  //  used to exit big loop before app exits

    //**********************************************************************************************
    //  these are used in findPrimesMultithreaded()
    let batchCount = 8
    var holdingDict: [Int:[HLPrimeType]] = [:]  //  needs to be protected for multithread
    var waitingForBatchId = 0                   //  needs to be protected for multithread

    var operationsQueue = OperationQueue()
    internal let semaphore = DispatchSemaphore(value: 1)
        
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

    func findPrimesSetup(maxPrime: HLPrimeType) {
        pTable = createPTable(maxPrime: maxPrime)
        (self.lastN, self.lastP) = (3, 5)   //  this is our starting point
        
 /*       if let primeURL = primeFileURL {
            let _ = fileManager.createTextFile(url: primeURL)
            let initialList: String = "1\t2\n2\t3\n3\t5\n"
            let _ = fileManager.appendStringToFile(initialList)
        }*/

        self.startDate = Date()  //  don't count the time to create pTable
    }
    
    func findPrimesCompletion(completion: @escaping (String) -> Void) {
        timeInSeconds = -Int(startDate.timeIntervalSinceNow)
        pTable.removeAll()
        fileManager.closeFileForWritting()
        print( "findPrimes-  final lastN: \(lastN)    lastP: \(lastP)" )
        lastLine = String(format: "%d\t%ld", self.lastN, lastP)
        
 /*       if !primeFileIsValid(primeFileURL) {
            print("    *********  findPrimes completed but primeFileIsValid() failed!!       ********* \n")
        }*/

        completion(lastLine)
    }
    
    //  uses DispatchQueue with maxConcurrentOperationCount set to processInfo.activeProcessorCount
    //  uses holdingDict to sync operation outputs
    func findPrimes3(primeURL: URL, maxPrime: HLPrimeType, completion: @escaping (String) -> Void) {
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
    func findPrimes2(primeURL: URL, maxPrime: HLPrimeType, completion: @escaping (String) -> Void) {
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
        semaphore.wait()
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
            if !compoundLine.isEmpty {
                self.fileManager.appendStringToFile(compoundLine)
            }
            
            holdingDict.removeValue(forKey: waitingForBatchId)
            waitingForBatchId += 1
        }
        semaphore.signal()
    }
    public func findPrimes(primeURL: URL, maxPrime: HLPrimeType, completion: @escaping HLCompletionClosure) {
        print( "\nHLPrime-  findPrimes-  maxPrime: \(maxPrime)" )
        
        let _ = fileManager.createTextFile(url: primeURL)
        let initialList: String = "1\t2\n2\t3\n"
        let _ = fileManager.appendStringToFile(initialList)
   //     print( "\nHLPrime-  findPrimes-  primesFileURL: \(String(describing: primesFileURL))   appendSuccess: \(appendSuccess)" )

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            self.okToRun = true //  must be above call to createPTable()
            self.pTable = self.createPTable(maxPrime: maxPrime)
            self.lastLine = "2\t3\n"
            (self.lastN, self.lastP) = self.lastLine.parseLine()   //  this is our starting point
            
            self.startDate = Date()  //  don't count the time to create pTable


           //***********************************************************************************
            while( maxPrime >= self.lastP && self.okToRun ) {
                if self.isPrime(self.lastP)    {
                    self.lastLine = String(format: "%d\t%ld\n", self.lastN, self.lastP)
                    self.fileManager.appendStringToFile(self.lastLine)
                    self.lastN += 1
                }
                self.lastP += 2
            }
            //***********************************************************************************


            self.timeInSeconds = -Int(self.startDate.timeIntervalSinceNow)
            self.fileManager.closeFileForWritting()
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
    func makeNicePrimesFile(primeURL: URL, nicePrimeURL: URL, completion: @escaping HLCompletionClosure)    {
        print( "HLPrime-  makeNicePrimesFile" )
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            var nextLine = self.fileManager.getLastLine(primeURL)

            (self.lastN, self.lastP) = nextLine.parseLine()
            let lastPrimeInPrimeFile = self.lastP
            
            //  now we can create pTable and begin testing for 'nice' primes
            self.pTable = self.createPTable(maxPrime: self.lastP)
                
            self.startDate = Date()
            
            let success = self.fileManager.openFileForRead(url: primeURL)
            guard success else { return }
            
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
            
            self.timeInSeconds = -Int(self.startDate.timeIntervalSinceNow)
            self.pTable.removeAll()
            self.fileManager.closeFileForReading()
            self.fileManager.closeFileForWritting()

            DispatchQueue.main.async {
                completion(self.lastLine)
            }
        }
        
        return
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

        print(String(format: "HLPrime-  createPTable completed in %0.2f seconds and has \(pTable.count) elements,  pTable last value: \(pTable[self.pTable.count - 1])", -Double(startDate.timeIntervalSinceNow)))
        return pTable
    }

    public init() {
        let processInfo = ProcessInfo()
        let numberOfCores = processInfo.activeProcessorCount
        operationsQueue.name = "HLPrimeFinderQueue"
        operationsQueue.maxConcurrentOperationCount = numberOfCores
        print("HLPrime-  init: numberOfCores: \(numberOfCores)")
    }
}
