//
//  HLPrime.swift
//  HLPrimes
//
//  Created by Matthew Homer on 5/28/17.
//  Copyright © 2017 HomerLabs. All rights reserved.
//

import Foundation

typealias HLPrimeType = Int64

protocol HLPrimesProtocol {
    func findPrimesCompleted()
    func factorPrimesCompleted()
}

class HLPrime: NSObject {

    let fileManager: HLFileManager!
    var primesFileURL: URL!
    var factoredFileURL: URL!
    var nicePrimesFileURL: URL!
    var active = true
    
    var lastN: Int = 0
    var lastP: HLPrimeType = 0
    var primeFileLastLine: String?
    var factorFileLastLine: String?
    var actionTimeInSeconds = 0     //  time for makePrimes, factorPrimes, or loadBuf to run
    var primesDelegate: HLPrimesProtocol?
    var pTable: HLPrimeTable!
    
    func findHighestPossiblePrime(terminalPrime: HLPrimeType) -> HLPrimeType    {
        var largestPrimeToFind = terminalPrime
        let largestTestPrime = Int64(sqrt(Double(largestPrimeToFind)))
        var largestPrimeNeeded = largestTestPrime
     
        let primeFileLastLine = fileManager.lastLine(forFile: primesFileURL.path)
            self.primeFileLastLine = primeFileLastLine
            let (_, lastP) = primeFileLastLine!.parseLine()

        if lastP < largestPrimeNeeded    {
            largestPrimeNeeded = lastP
            largestPrimeToFind = lastP * lastP
        }

        return largestPrimeToFind
    }

    func findPrimes(largestPrime: HLPrimeType)    {
        
        DispatchQueue.global(qos: .userInitiated).async {
            let startDate = Date()
            self.fileManager.createPrimeFileIfNeeded(with: self.primesFileURL.path)

            print( "\nHLPrime-  findPrimes-  largestPrime: \(largestPrime)" )
            
            self.primeFileLastLine = self.fileManager.lastLine(forFile: self.primesFileURL.path)
            (self.lastN, self.lastP) = self.primeFileLastLine!.parseLine()
            var highestPossiblePrime = self.findHighestPossiblePrime(terminalPrime: largestPrime)
            
            while self.lastP < largestPrime   {
                let largestTestPrime = Int64(sqrt(Double(highestPossiblePrime)))
                self.pTable = HLPrimeTable(primeFileURL: self.primesFileURL, largestPrime: largestTestPrime)
                print( "pTable loaded-  lastN: \(self.pTable.buf.count)    lastP: \(self.pTable.buf[self.pTable.buf.count-1])" )

                //  find out where we left off and continue from there
                //        (self.lastN, self.lastP) = primeFileLastLine!.parseLine()
                print( "findPrimes-  starting at lastN: \(self.lastN)    lastP: \(self.lastP)" )
                self.fileManager.openPrimesFileForAppend(with: self.primesFileURL.path)

                self.lastN += 1
                self.lastP += 2

                while( highestPossiblePrime >= self.lastP ) {

                    if self.isPrime(n: self.lastP)    {
                        let output = String(format: "%d\t%ld\n", self.lastN, self.lastP)
                        self.fileManager.appendPrimesLine(output)
                        self.lastN += 1
                    }

                    self.lastP += 2

                    if !self.active   {
                        break
                    }
                }
 
                self.fileManager.closePrimesFileForAppend()
                highestPossiblePrime = self.findHighestPossiblePrime(terminalPrime: largestPrime)
           }

            

            DispatchQueue.main.async {
                self.primeFileLastLine = self.fileManager.lastLine(forFile: self.primesFileURL.path)
                let (newLastN, newLastP) = self.primeFileLastLine!.parseLine()
                print( "findPrimes-  final lastN: \(newLastN)    lastP: \(newLastP)" )
                self.actionTimeInSeconds = -Int(startDate.timeIntervalSinceNow)
 //               print( "HLPrime-  makePrimes-  completed.  Time: \(self.formatTime(timeInSeconds: deltaTime))" )

                self.primesDelegate?.findPrimesCompleted()
            }
        }
    }

    func factorPrimes(largestPrime: HLPrimeType)  {

        DispatchQueue.global(qos: .userInitiated).async {
            print( "\nHLPrime-  factorPrimes-  largestPrime: \(largestPrime)" )
    //        guard self.fileManager.createPrimeFileIfNeeded(self.primesFileURL) == 0     else    {   return     }
            
            let startDate = Date()
            var largestPrimeToFactor = largestPrime
            var largestPrimeNeeded = (largestPrimeToFactor-1) / 2
            
            if self.lastP < largestPrimeNeeded  {
                largestPrimeNeeded = self.lastP
                largestPrimeToFactor = (self.lastP+1) * 2
                print( "Adjusted largestPrimeToFactor from: \(largestPrime) to: \(largestPrimeToFactor)" )
            }

            self.pTable = HLPrimeTable(primeFileURL: self.primesFileURL, largestPrime: largestPrimeNeeded)
            print( "pTable loaded-  count: \(self.pTable.buf.count)    highest prime: \(self.pTable.buf[self.pTable.buf.count-1])" )
            
            var lastfactored: HLPrimeType = 3
            if let factoredLastLine = self.fileManager.lastLine(forFile: self.factoredFileURL.path) {
                lastfactored = factoredLastLine.prefixInt64()
                if lastfactored < 3     {   lastfactored = 3    }
            }

            let primesErrorCode = self.fileManager.openPrimesFileForRead(with: self.primesFileURL.path)
            let factoredErrorCode = self.fileManager.openFactoredFileForAppend(with: self.factoredFileURL.path)
            assert( primesErrorCode == 0 )
            assert( factoredErrorCode == 0 )

            self.lastP = 0
            while self.lastP != lastfactored {    //  advance to the next prime to factor
                let line = self.fileManager.readPrimesFileLine()
                (_, self.lastP) = line!.parseLine()
            }

//            print( "HLPrime-  factorPrimes-  lastP: \(self.lastP)" )

            var lastPrimeLine = self.fileManager.readPrimesFileLine()
            (_, self.lastP) = lastPrimeLine!.parseLine()

            while self.lastP <= largestPrimeToFactor {
                let factoredPrime = self.factor(prime: self.lastP)
                self.fileManager.appendFactoredLine(factoredPrime)
                
                lastPrimeLine = self.fileManager.readPrimesFileLine()
                if lastPrimeLine == nil     {   break   }   //  watch for end of file
                if !self.active             {   break   }   //  watch for user stop action
                (_, self.lastP) = lastPrimeLine!.parseLine()
         }

            self.fileManager.closeFactoredFileForAppend()
            self.fileManager.closePrimesFileForRead()
        
            DispatchQueue.main.async {
                self.factorFileLastLine = self.fileManager.lastLine(forFile: self.factoredFileURL.path)
                self.actionTimeInSeconds = -Int(startDate.timeIntervalSinceNow)
    //              print( "HLPrime-  factorPrimes-  completed.  Time: \(self.formatTime(timeInSeconds: deltaTime))" )

                self.primesDelegate?.factorPrimesCompleted()
            }
        }
    }
    
    func lastLineFor(path: String) -> String?   {
        let lastLine = fileManager.lastLine(forFile: path)
 //       print( "HLPrime.lastLineFor: \(path)   \(String(describing: lastLine))" )
        return lastLine
    }

    func isPrime(n: HLPrimeType) -> Bool    {
        var isPrime = true
        let largestTestPrime = Int(sqrt(Double(n)))
        
        var index = 1   //  we don't try the value in [0] == 2
        var testPrime = pTable.buf[index]
        while testPrime <= largestTestPrime {
            let q_r = lldiv(n, testPrime)
            if q_r.rem == 0 {
                isPrime = false
                break
            }
            
            if testPrime == largestTestPrime    {
                break
            }
            
            index += 1
            testPrime = pTable.buf[index]
        }
        
//        print( "HLPrime-  isPrime-  n: \(n)   isPrime: \(isPrime)" )
        return isPrime
    }
    
    func factor(prime: HLPrimeType) -> String   {
        var value = (prime - 1) / 2
        var result = String(prime)
        
        let largestTestPrime = prime / 2    //  not sqrt()
        var index = 0   //  start with testPrime = 2
        var testPrime = pTable.buf[index]
        
        repeat  {
            var q_r = lldiv(value, testPrime)
            while q_r.rem == 0 {
                value /= testPrime
                result.append("\t" + String(testPrime))
                q_r = lldiv(value, testPrime)
            }
            
            index += 1
            testPrime = pTable.buf[index]
        } while testPrime <= largestTestPrime && value > 1
        
//        print( "final: \(result)" )
        return result
    }
    
   func makeNicePrimesFile()    {
        print( "HLPrime-  makeNicePrimesFile" )
        fileManager.openFactoredFileForRead(with: factoredFileURL.path)
        fileManager.openNicePrimesFileForWrite(with: nicePrimesFileURL.path)
    
        var line = fileManager.readFactoredFileLine()
        var lastN = 3   //  first prime in factored file is '5'
        if line != nil  {
            repeat  {
                var tabCount = 0
                let tab = 9   //  ascii tab
                let charCount = line!.count
                let cString = line!.utf8CString
                
                for index in 0..<charCount {
                    let charValue = cString[index]
                    if charValue == tab    {
                        tabCount += 1
                    }
                }
                
                if tabCount == 1 {
                    let lastP = line!.prefixInt64()
                    let outputLine = "\(lastN)\t\(lastP)"
                    fileManager.writeNicePrimesFile(outputLine)
                }

                line = fileManager.readFactoredFileLine()
                lastN += 1
            }   while line != nil

            fileManager.closeNicePrimesFileForWrite()
            fileManager.closeFactoredFileForRead()
        }
    }
    
    
    func setupFilePaths(basePath: String)   {
  //      print( "HLPrime.setupFilePaths-  basePath: \(basePath)" )
        primesFileURL = URL(string: basePath)
        factoredFileURL = URL(string: basePath + "-F")
        nicePrimesFileURL = URL(string: basePath + "-N")
    }

    init(primeFilePath: String, modCount: Int32, delegate: HLPrimesProtocol)  {
        fileManager = HLFileManager(modCount)
        primesDelegate = delegate
        super.init()
        setupFilePaths(basePath: primeFilePath)
        print( "HLPrime.init-  primeFilePath: \(primesFileURL.path)" )

        if let primeFileLastLine = fileManager.lastLine(forFile: primesFileURL.path) {
            self.primeFileLastLine = primeFileLastLine
            (lastN, lastP) = primeFileLastLine.parseLine()
            print( "Primes file found: '\(primesFileURL.lastPathComponent)' last line:  lastN: \(lastN)    lastP: \(lastP)" )
        }

        if let factorFileLastLine = fileManager.lastLine(forFile: factoredFileURL.path) {
            self.factorFileLastLine = factorFileLastLine
            print( "Factored file found: '\(factoredFileURL.lastPathComponent)' last line: \(factorFileLastLine)" )
        }
    }
}

