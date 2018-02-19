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
    func findPrimesCompleted(lastLine: String)
    func findNicePrimesCompleted(lastLine: String)
}


class HLPrime: NSObject {

    let fileManager: HLFileManager!
    var primesFile: String
    var factoredFile: String?
    var nicePrimesFile: String?
    var active = true
    
    var lastN: Int = 0
    var lastP: HLPrimeType = 0
    var primeFileLastLine: String?
    var factorFileLastLine: String?
    var actionTimeInSeconds = 0     //  time for makePrimes, factorPrimes, or loadBuf to run
    var primesDelegate: HLPrimesProtocol?
    var pTable: HLPrimeTable!
    
   func makeNicePrimesFile(nicePrimePath: String, largestPrime: HLPrimeType)    {

        DispatchQueue.global(qos: .userInitiated).async {
            let startDate = Date()
            self.nicePrimesFile = nicePrimePath
            var lastLine = ""
            print( "HLPrime-  makeNicePrimesFile-  largestPrime: \(largestPrime)" )
        
            let largestTestPrime = Int64(sqrt(Double((largestPrime-1)/2)))
            self.pTable = HLPrimeTable(primeFile: self.primesFile, largestPrime: largestTestPrime)
            print( "pTable loaded-  lastN: \(self.pTable.buf.count)    lastP: \(self.pTable.buf[self.pTable.buf.count-1])" )

            self.fileManager.openPrimesFileForRead(with: self.primesFile)
            self.fileManager.openNicePrimesFileForWrite(with: self.nicePrimesFile)
        
            var line = self.fileManager.readPrimesFileLine()
            line = self.fileManager.readPrimesFileLine()
            line = self.fileManager.readPrimesFileLine()
        
            if line == nil  {   return  }
            (_, self.lastP) = line!.parseLine()
        
            while self.lastP<largestPrime && self.active   {
                let possiblePrime = (self.lastP-1)/2
                
                if self.isPrime(n: possiblePrime) {
                    self.fileManager.writeNicePrimesFile(line)
                    lastLine = line!
                }

                line = self.fileManager.readPrimesFileLine()
                if line != nil  {
                    (_, self.lastP) = line!.parseLine()
                }
                else    {   break   }
           }

            self.fileManager.closeNicePrimesFileForWrite()
            self.fileManager.closePrimesFileForRead()

            DispatchQueue.main.async {
                self.actionTimeInSeconds = -Int(startDate.timeIntervalSinceNow)
                self.pTable.deleteTable()
                self.primesDelegate?.findNicePrimesCompleted(lastLine: lastLine)
            }
        }
    }
    
    
    func findPrimes(largestPrime: HLPrimeType)    {
    
        let success = self.fileManager.createPrimeFileIfNeeded(with: primesFile)
        if !success {
            print( "\nHLPrime-  findPrimes-  largestPrime: \(largestPrime) failed!  Unable to create prime file: \(String(describing: primesFile))" )
            primeFileLastLine = "0\t0\n"
            primesDelegate?.findPrimesCompleted(lastLine: primeFileLastLine!)
            return  //  we don't have file access permission
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let startDate = Date()
            var output = ""

            print( "\nHLPrime-  findPrimes-  largestPrime: \(largestPrime)" )
            
            self.primeFileLastLine = self.fileManager.lastLine(forFile: self.primesFile)
            (self.lastN, self.lastP) = self.primeFileLastLine!.parseLine()
            var highestPossiblePrime = self.findHighestPossiblePrime(terminalPrime: largestPrime)
            
            self.lastN += 1
            self.lastP += 2

           while self.lastP<largestPrime && self.active   {
                let largestTestPrime = Int64(sqrt(Double(highestPossiblePrime)))
                self.pTable = HLPrimeTable(primeFile: self.primesFile, largestPrime: largestTestPrime)
                print( "pTable loaded-  lastN: \(self.pTable.buf.count)    lastP: \(self.pTable.buf[self.pTable.buf.count-1])" )

                //  find out where we left off and continue from there
                //        (self.lastN, self.lastP) = primeFileLastLine!.parseLine()
                let density = Float80(self.lastN) / Float80(self.lastP)
                print( "findPrimes-  starting at lastN: \(self.lastN)    lastP: \(self.lastP)    density: \(density)" )
                self.fileManager.openPrimesFileForAppend(with: self.primesFile)

                while( highestPossiblePrime >= self.lastP ) {
                
                    if self.isPrime(n: self.lastP)    {
                        output = String(format: "%d\t%ld\n", self.lastN, self.lastP)
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
                self.pTable.deleteTable()
            }

            

            DispatchQueue.main.async {
                output.removeLast()
                self.primeFileLastLine = output
                let (newLastN, newLastP) = self.primeFileLastLine!.parseLine()
                print( "findPrimes-  final lastN: \(newLastN)    lastP: \(newLastP)" )
                self.actionTimeInSeconds = -Int(startDate.timeIntervalSinceNow)
                self.pTable.deleteTable()
 //               print( "HLPrime-  makePrimes-  completed.  Time: \(self.formatTime(timeInSeconds: deltaTime))" )

                self.primesDelegate?.findPrimesCompleted(lastLine: output)
            }
        }
    }

    func factorPrimes(largestPrime: HLPrimeType)  {

        DispatchQueue.global(qos: .userInitiated).async {
            print( "HLPrime-  factorPrimes-  largestPrime: \(largestPrime)" )
            
            let startDate = Date()
            var largestPrimeToFactor = largestPrime
            var largestPrimeNeeded = (largestPrimeToFactor-1) / 2
            
            if self.lastP < largestPrimeNeeded  {
                largestPrimeNeeded = self.lastP
                largestPrimeToFactor = (self.lastP+1) * 2
                print( "Adjusted largestPrimeToFactor from: \(largestPrime) to: \(largestPrimeToFactor)" )
            }

            self.pTable = HLPrimeTable(primeFile: self.primesFile, largestPrime: largestPrimeNeeded)
            print( "pTable loaded-  count: \(self.pTable.buf.count)    highest prime: \(self.pTable.buf[self.pTable.buf.count-1])" )
            
            var lastfactored: HLPrimeType = 3
            if let factoredLastLine = self.fileManager.lastLine(forFile: self.factoredFile) {
                lastfactored = factoredLastLine.prefixInt64()
                if lastfactored < 3     {   lastfactored = 3    }
            }

            let primesErrorCode = self.fileManager.openPrimesFileForRead(with: self.primesFile)
            let factoredErrorCode = self.fileManager.openFactoredFileForAppend(with: self.factoredFile)
            assert( primesErrorCode == 0 )
            assert( factoredErrorCode == 0 )

            self.lastP = 0
            while self.lastP != lastfactored {    //  advance to the next prime to factor
                let line = self.fileManager.readPrimesFileLine()
                (_, self.lastP) = line!.parseLine()
            }

//            print( "HLPrime-  factorPrimes-  lastP: \(self.lastP)" )

            var lastPrimeLine = self.fileManager.readPrimesFileLine()
            if lastPrimeLine != nil {
                (_, self.lastP) = lastPrimeLine!.parseLine()

                while self.lastP <= largestPrimeToFactor {
                    let factoredPrime = self.factor(prime: self.lastP)
                    self.fileManager.appendFactoredLine(factoredPrime)
                    
                    lastPrimeLine = self.fileManager.readPrimesFileLine()
                    if lastPrimeLine == nil     {   break   }   //  watch for end of file
                    if !self.active             {   break   }   //  watch for user stop action
                    (_, self.lastP) = lastPrimeLine!.parseLine()
                }
            }

            self.fileManager.closeFactoredFileForAppend()
            self.fileManager.closePrimesFileForRead()
        
            DispatchQueue.main.async {
                self.factorFileLastLine = self.fileManager.lastLine(forFile: self.factoredFile)
                self.actionTimeInSeconds = -Int(startDate.timeIntervalSinceNow)
                self.pTable.deleteTable()
    //              print( "HLPrime-  factorPrimes-  completed.  Time: \(self.formatTime(timeInSeconds: deltaTime))" )

      //          self.primesDelegate?.factorPrimesCompleted()
            }
        }
    }
    
    func findHighestPossiblePrime(terminalPrime: HLPrimeType) -> HLPrimeType    {
        var largestPrimeToFind = terminalPrime
        let largestTestPrime = Int64(sqrt(Double(largestPrimeToFind)))
        var largestPrimeNeeded = largestTestPrime
     
        let primeFileLastLine = fileManager.lastLine(forFile: primesFile)
            self.primeFileLastLine = primeFileLastLine
            let (_, lastP) = primeFileLastLine!.parseLine()

        if lastP < largestPrimeNeeded    {
            largestPrimeNeeded = lastP
            largestPrimeToFind = lastP * lastP
        }

        return largestPrimeToFind
    }

    func lastLineFor(path: String) -> String?   {
        let lastLine = fileManager.lastLine(forFile: path)
 //       print( "HLPrime.lastLineFor: \(path)   \(String(describing: lastLine))" )
        return lastLine
    }

    func isPrime(n: HLPrimeType) -> Bool    {
        var isPrime = true
        let largestTestPrime = Int(sqrt(Double(n)))
        
//        var index = 1   //  we don't try the value in [0] == 2
        var index = 0   //  we do try the value in [0] == 2
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
    

    init(primeFilePath: String, delegate: HLPrimesProtocol)  {
        fileManager = HLFileManager()
        primesDelegate = delegate
        primesFile = primeFilePath

        super.init()
        print( "HLPrime.init-  primeFilePath: \(primesFile)" )


 /*          if let primeFileLastLine = self.fileManager.lastLine(forFile: self.primesFileURL.path) {
                self.primeFileLastLine = primeFileLastLine
                (self.lastN, self.lastP) = primeFileLastLine.parseLine()
                print( "Primes file found: '\(self.primesFileURL.lastPathComponent)' last line:  lastN: \(self.lastN)    lastP: \(self.lastP)" )
            }

            if let factorFileLastLine = self.fileManager.lastLine(forFile: self.factoredFileURL.path) {
                self.factorFileLastLine = factorFileLastLine
                print( "Factored file found: '\(self.factoredFileURL.lastPathComponent)' last line: \(factorFileLastLine)" )
            }   */
    }
}

