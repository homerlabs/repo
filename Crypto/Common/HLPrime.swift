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
    func loadBufCompleted()
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
    var actionTimeInSeconds = 0     //  time for makePrimes, factorPrimes, or loadBuf to run
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
        while testPrime <= largestTestPrime {
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
        DispatchQueue.global(qos: .background).async {
            guard self.fileManager.createPrimeFileIfNeeded(self.primesFileURL) == 0  else    {   return }

            let startDate = Date()
            let openResult = self.fileManager.openPrimesFileForRead(with: self.primesFileURL.path)
            if openResult == 0  {
                repeat  {
                    if let nextLine = self.fileManager.readPrimesFileLine()    {
                        (self.lastN, self.lastP) = self.parseLine(line: nextLine)
                        self.buf.append(self.lastP)
                    }
                    else    {
                        break
                    }
                } while self.largestBufPrime < largestPrime
                
                self.largestBufPrime = self.lastP
                self.fileManager.closePrimesFileForRead()
         
                //  this will be nil if prime file doesn't exist
                if self.primeFileLastLine == nil {
                    self.primeFileLastLine = self.fileManager.lastLine(forFile: self.primesFileURL.path)
                }
            }
            
            
            DispatchQueue.main.async {
                self.actionTimeInSeconds = -Int(startDate.timeIntervalSinceNow)
                self.primesDelegate?.loadBufCompleted()
            }
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
        print( "HLPrime-  makeNicePrimesFile" )
        fileManager.openFactoredFileForRead(with: factoredFileURL.path)
        fileManager.openNicePrimesFileForWrite(with: nicePrimesFileURL.path)
    
        var line = fileManager.readFactoredFileLine()
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
                    fileManager.writeNicePrimesFile(line)
                }

                line = fileManager.readFactoredFileLine()
            }   while line != nil

            fileManager.closeNicePrimesFileForWrite()
            fileManager.closeFactoredFileForRead()
        }
    }

    func factorPrimes(largestPrime: HLPrimeType)  {
        DispatchQueue.global(qos: .background).async {
            guard self.fileManager.createPrimeFileIfNeeded(self.primesFileURL) == 0  else    {   return }

            print( "HLPrime-  factorPrimes-  largestPrime: \(largestPrime)" )
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

                    self.lastP = 0
                    repeat {    //  advance to the next prime to factor
                        let line = self.fileManager.readPrimesFileLine()
                        (_, self.lastP) = self.parseLine(line: line!)
                    } while self.lastP != lastfactor

                    print( "HLPrime-  factorPrimes-  lastP: \(self.lastP)" )

                    let lastPrimeLine = self.fileManager.lastLine(forFile: self.primesFileURL.path)!
                    (self.lastN, self.lastP) = self.parseLine(line: lastPrimeLine)
                    print( "factorPrimes-  Starting at-  lastN: \(self.lastN)    lastP: \(self.lastP)" )
                   
                    repeat {
                        let line = self.fileManager.readPrimesFileLine()
                        if line == nil  {   break   }   //  watch for end of file
                        
                        (_, self.lastP) = self.parseLine(line: line!)
                        let factoredPrime = self.factor(prime: self.lastP)
                        self.fileManager.appendFactoredLine(factoredPrime)
 
                        if !self.active   {
                            break
                        }
                   } while self.lastP <= largestPrime
                }

                self.fileManager.closeFactoredFileForAppend()
                self.fileManager.closePrimesFileForRead()
            }
            
            DispatchQueue.main.async {
                self.factorFileLastLine = self.fileManager.lastLine(forFile: self.factoredFileURL.path)
                self.actionTimeInSeconds = -Int(startDate.timeIntervalSinceNow)
  //              print( "HLPrime-  factorPrimes-  completed.  Time: \(self.formatTime(timeInSeconds: deltaTime))" )

                self.primesDelegate?.factorPrimesCompleted()
            }
        }
    }
    
    func makePrimes(largestPrime: HLPrimeType)  {
        DispatchQueue.global(qos: .background).async {
            guard self.fileManager.createPrimeFileIfNeeded(self.primesFileURL) == 0  else    {   return }
            
            print( "HLPrime-  makePrimes-  largestPrime: \(largestPrime)" )
            let startDate = Date()
            self.primeFileLastLine = self.fileManager.lastLine(forFile: self.primesFileURL.path)

             //  find out where we left off and continue from there
            (self.lastN, self.lastP) = self.parseLine(line: self.primeFileLastLine!)
            print( "current makePrimes-  lastN: \(self.lastN)    lastP: \(self.lastP)" )

            self.lastN += 1
            self.lastP += 2

            self.fileManager.openPrimesFileForAppend(with: self.primesFileURL.path)

            while( largestPrime >= self.lastP ) {
                
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

            DispatchQueue.main.async {
                self.primeFileLastLine = self.fileManager.lastLine(forFile: self.primesFileURL.path)
                let (newLastN, newLastP) = self.parseLine(line: self.primeFileLastLine!)
                print( "new makePrimes-  lastN: \(newLastN)    lastP: \(newLastP)" )
                self.actionTimeInSeconds = -Int(startDate.timeIntervalSinceNow)
 //               print( "HLPrime-  makePrimes-  completed.  Time: \(self.formatTime(timeInSeconds: deltaTime))" )

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
            print( "\(primesFileURL.path) found. last line:  lastN: \(lastN)    lastP: \(lastP)" )
        }

        if let factorFileLastLine = fileManager.lastLine(forFile: factoredFileURL.path) {
            self.factorFileLastLine = factorFileLastLine
            print( "\(factoredFileURL.path) found. last line: \(factorFileLastLine)" )
        }
    }
}

