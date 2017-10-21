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
    func makePrimesCompleted()
    func factorPrimesCompleted()
}


class HLPrime: NSObject {

    let fileManager: HLFileManager!
    var primesFileURL: URL!
    var factoredFileURL: URL!
    var nicePrimesFileURL: URL!
    var buf: [HLPrimeType] = []
    var largestBufPrime: HLPrimeType = 0
    var active = true
    
    var lastN: Int = 0
    var lastP: HLPrimeType = 0
    var primeFileLastLine: String?
    var factorFileLastLine: String?
    var primesDelegate: HLPrimesProtocol?
    

    func lastLineFor(path: String) -> String?   {
        let lastLine = fileManager.lastLine(forFile: path)
//        print( "lastLineFor: \(path)   \(lastLine)" )
        return lastLine
    }

    func isPrime(n: HLPrimeType) -> Bool    {
        var isPrime = true
        let largestTestPrime = Int(sqrt(Double(n)))
        
        var index = 1   //  we don't try the value in [0] == 2
        var testPrime = buf[index]
        while testPrime < largestTestPrime {
            let q_r = lldiv(n, testPrime)
            if q_r.rem == 0 {
                isPrime = false
                break
            }
            
            index += 1
            testPrime = buf[index]
        }
        
//        print( "HLPrime-  isPrime-  n: \(n)   isPrime: \(isPrime)" )
        return isPrime
    }
    
    func loadBufFor(largestPrime: HLPrimeType) -> Int   {
        let openResult = fileManager.openPrimesFileForRead(with: primesFileURL.path)     //  creates one if needed
        if openResult != 0  {   //  BAIL!
            return -1
        }
        
        repeat  {
            if let nextLine = fileManager.readPrimesFileLine()    {
                let (_, valueP) = parseLine(line: nextLine)
                let prime = Int64(valueP)
                buf.append(prime)
                largestBufPrime = prime
            }
            else    {
                break
            }
        } while largestBufPrime < largestPrime
        
        fileManager.closePrimesFileForRead()
 //       print( "loadBuf: \(buf)" )
 
        //  this will be nil if prime file doesn't exist
        if primeFileLastLine == nil {
            primeFileLastLine = fileManager.lastLine(forFile: primesFileURL.path)
        }
        
        return 0
    }
    
    func factor(prime: HLPrimeType) -> String   {
        var value = (prime - 1)/2
        var result = String(prime)
        
        let largestTestPrime = prime / 2    //  not sqrt()
        var index = 0   //  start with testPrime = 2
        var testPrime = buf[index]
        
        repeat  {
            var q_r = lldiv(value, testPrime)
            while q_r.rem == 0 {
                value /= testPrime
                result.append("\t" + String(testPrime))
                q_r = lldiv(value, testPrime)
            }
            
            index += 1
            testPrime = buf[index]
        } while testPrime <= largestTestPrime && value > 1
        
//        print( "final: \(result)" )
        return result
    }
    
   func makeNicePrimesFile()    {
        print( "\nHLPrime-  makeNicePrimesFile" )
        fileManager.openFactoredFileForRead(with: factoredFileURL.path)
        fileManager.openNicePrimesFileForWrite(with: nicePrimesFileURL.path)
    
        var line = fileManager.readFactoredFileLine()
        if line != nil  {
            repeat  {
                var tabCount = 0
                let tab = 9   //  ascii tab
                let charCount = line!.characters.count
                let cString = line!.utf8CString
                
                for index in 0..<charCount {
                    let charValue = cString[index]
                    if charValue == tab    {
                        tabCount += 1
                    }
                }
                
                if tabCount == 1 {
                    fileManager.writeNicePrimesFile(line)
                }

                line = fileManager.readFactoredFileLine()
            }   while line != nil

            fileManager.closeNicePrimesFileForWrite()
            fileManager.closeFactoredFileForRead()
        }
    }

    func factorPrimes(largestPrime: HLPrimeType) -> Int  {
        DispatchQueue.global(qos: .background).async {
            print( "\nHLPrime-  factorPrimes-  largestPrime: \(largestPrime)" )
            let startDate = Date()
            
            let errorCode = self.fileManager.openFactoredFileForAppend(with: self.factoredFileURL.path)
            if errorCode == 0   {
                self.fileManager.closeFactoredFileForAppend()

                var lastLine = self.fileManager.lastLine(forFile: self.factoredFileURL.path)!
                
                if let index = lastLine.index(of: "\t") {
                    lastLine = String(lastLine.prefix(upTo: index))
                }
                
                let lastfactor = Int64(lastLine)
                if lastfactor != nil {
             //       print( "HLPrime-  factorPrimes-  lastfactor: \(lastfactor!)" )
                    
                    let primesErrorCode = self.fileManager.openPrimesFileForRead(with: self.primesFileURL.path)
                    let factoredErrorCode = self.fileManager.openFactoredFileForAppend(with: self.factoredFileURL.path)
                    assert( primesErrorCode == 0 )
                    assert( factoredErrorCode == 0 )

                    var nextP: HLPrimeType = 0
                    repeat {    //  advance to the next prime to factor
                        let line = self.fileManager.readPrimesFileLine()
                        (_, nextP) = self.parseLine(line: line!)
                    } while nextP != lastfactor

                    print( "HLPrime-  factorPrimes-  lastP: \(nextP)" )

                    let lastPrimeLine = self.fileManager.lastLine(forFile: self.primesFileURL.path)!
                    (self.lastN, self.lastP) = self.parseLine(line: lastPrimeLine)
                    print( "factorPrimes-  Starting at-  lastN: \(self.lastN)    lastP: \(self.lastP)" )
                   
                    repeat {
                        let line = self.fileManager.readPrimesFileLine()
                        if line == nil  {   break   }   //  watch for end of file
                        
                        (_, nextP) = self.parseLine(line: line!)
                        let factoredPrime = self.factor(prime: nextP)
                        self.fileManager.appendFactoredLine(factoredPrime)
 
                        if !self.active   {
                            break
                        }
                   } while nextP != min(largestPrime, self.lastP)
                }

                self.fileManager.closeFactoredFileForAppend()
                self.fileManager.closePrimesFileForRead()
            }
            

            DispatchQueue.main.async {
                self.factorFileLastLine = self.fileManager.lastLine(forFile: self.factoredFileURL.path)
                let deltaTime = -Int(startDate.timeIntervalSinceNow)
                print( "HLPrime-  factorPrimes-  completed.  Time: \(self.formatTime(timeInSeconds: deltaTime))" )

                self.primesDelegate?.factorPrimesCompleted()
            }
        }
        
        return 0
    }
    
    func makePrimes(largestPrime: HLPrimeType)  {
        DispatchQueue.global(qos: .background).async {
            print( "\nHLPrime-  makePrimes-  largestPrime: \(largestPrime)" )
            let startDate = Date()

             //  find out where we left off and continue from there
            let (lastN, lastP) = self.parseLine(line: self.primeFileLastLine!)
            print( "current makePrimes-  lastN: \(lastN)    lastP: \(lastP)" )

            var nextN = lastN + 1
            var nextP = lastP + 2

            self.fileManager.openPrimesFileForAppend(with: self.primesFileURL.path)

            while( largestPrime >= nextP ) {
                
                if self.isPrime(n: nextP)    {
                    let output = String(format: "%d\t%ld\n", nextN, nextP)
                    self.fileManager.appendPrimesLine(output)
                    nextN += 1
                }
                
                nextP += 2

                if !self.active   {
                    break
                }
            }
            
            self.fileManager.closePrimesFileForAppend()

            DispatchQueue.main.async {
                self.primeFileLastLine = self.fileManager.lastLine(forFile: self.primesFileURL.path)
                let (newLastN, newLastP) = self.parseLine(line: self.primeFileLastLine!)
                print( "new makePrimes-  lastN: \(newLastN)    lastP: \(newLastP)" )
                let deltaTime = -Int(startDate.timeIntervalSinceNow)
                print( "HLPrime-  makePrimes-  completed.  Time: \(self.formatTime(timeInSeconds: deltaTime))" )

                self.primesDelegate?.makePrimesCompleted()
            }
        }
    }

    func parseLine(line: String) -> (index: Int, prime: Int64)  {
        if let index = line.index(of: "\t") {
            let index2 = line.index(after: index)
            let lastN = line.prefix(upTo: index)
            let lastP = line.suffix(from: index2)
            return (Int(lastN)!, Int64(lastP)!)
        }
        else    {
            return (0, 0)
        }
    }
    
    func formatTime(timeInSeconds: Int) -> String   {
        let hours = timeInSeconds / 3600
        let mintues = timeInSeconds / 60 - hours * 3600
        let seconds = timeInSeconds - hours * 3600 - mintues * 60
        return String(format: "%02d:%02d:%02d", hours, mintues, seconds)
    }

    init(primeFilePath: String, modCount: Int32, delegate: HLPrimesProtocol)  {
        fileManager = HLFileManager(modCount)
        primesDelegate = delegate
        super.init()
         print( "HLPrime.init-  primeFilePath: \(primeFilePath)" )

        primesFileURL = URL(string: primeFilePath)
        factoredFileURL = URL(string: primeFilePath + "-F")
        nicePrimesFileURL = URL(string: primeFilePath + "-N")

        if let primeFileLastLine = fileManager.lastLine(forFile: primesFileURL.path) {
            self.primeFileLastLine = primeFileLastLine
            (lastN, lastP) = parseLine(line: primeFileLastLine)
            print( "HLPrime.init-  lastN: \(lastN)    lastP: \(lastP)" )
        }

        if let factorFileLastLine = fileManager.lastLine(forFile: factoredFileURL.path) {
            self.factorFileLastLine = factorFileLastLine
            print( "HLPrime.init-  factorFileLastLine: \(factorFileLastLine)" )
        }
    }
}

