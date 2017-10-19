//
//  HLPrime.swift
//  HLPrimes
//
//  Created by Matthew Homer on 5/28/17.
//  Copyright © 2017 HomerLabs. All rights reserved.
//

import Foundation

typealias HLPrimeType = Int64


class HLPrime: NSObject {

    let fileManager: HLFileManager!
    var primesFileURL: URL!
    var factoredFileURL: URL!
    var nicePrimesFileURL: URL!
    let bufSize = 100
    var buf: [HLPrimeType] = []
    var largestBufPrime: HLPrimeType = 0
    var active = true
    
    var lastN: Int = 0
    var lastP: HLPrimeType = 0
    var primeFileLastLine: String?
    var factorFileLastLine: String?

    func lastLineFor(path: String) -> String?   {
        let lastLine = fileManager.lastLine(forFile: path)
//        print( "lastLineFor: \(path)   \(lastLine)" )
        return lastLine
    }

    func isPrime(n: HLPrimeType) -> Bool    {
        var isPrime = true
        let largestTestPrime = Int(sqrt(Double(n)))
        
 /*       if largestTestPrime > largestBufPrime   {
            print( "HLPrime-  isPrime-  largestTestPrime: \(largestTestPrime)  largestBufPrime: \(largestBufPrime)" )
            assert( false )
        }   */
        
        var index = 1   //  we don't try the value in [0] == 2
        var testPrime = buf[index]
        while testPrime <= largestTestPrime {
            let q_r = lldiv(n, testPrime)
            if q_r.rem == 0 {
                isPrime = false
                break
            }
            
            index += 1
            testPrime = getPrimeInBufAt(index: index)
            if testPrime == 0   {
                active = false
                break
            }
        }
        
//        print( "HLPrime-  isPrime-  n: \(n)   isPrime: \(isPrime)" )
        return isPrime
    }
    
    func loadBufFor(prime: HLPrimeType) -> Int   {
        let openResult = fileManager.openPrimesFileForRead(with: primesFileURL.path)     //  creates one if needed
        if openResult != 0  {   //  BAIL!
            return -1
        }
        
        let largestTestPrime = Int(sqrt(Double(prime)))

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
        } while largestBufPrime < largestTestPrime
        
        fileManager.closePrimesFileForRead()
 //       print( "loadBuf: \(buf)" )
 
        //  this will be nil if prime file didn't exist
        if primeFileLastLine == nil {
            primeFileLastLine = fileManager.lastLine(forFile: primesFileURL.path)
        }
        
        return 0
    }
    
    func getPrimeInBufAt(index: Int) -> HLPrimeType   {
        if index >= buf.count   {
            assert( false )
  /*          if let nextLine = fileManager.readLine()    {
                let (_, lastP) = parseLine(line: nextLine)
                let prime = Int64(lastP)
                buf.append(prime)
                largestBufPrime = prime
            }
            else    {
                return 0
            }   */
        }
        return buf[index]
    }
    
    func factor(prime: HLPrimeType) -> String   {
        var value = (prime - 1)/2
        var result = String(prime)
        
        let largestTestPrime = Int64(sqrt(Double(prime)))
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
        } while testPrime < largestTestPrime && value > 1
        
//        print( "final: \(result)" )
        return result
    }
    
   func makeNicePrimesFile()    {
        print( "\nHLPrime-  makeNicePrimesFile" )
        fileManager.openFactoredFileForRead(with: factoredFileURL.path)
        fileManager.openNicePrimesFileForWrite(with: nicePrimesFileURL.path)
    
        var line = fileManager.readPrimesFileLine()
    
        repeat  {
            let index = line!.index(of: "\t")
            if index == nil {
                fileManager.writeNicePrimesFile(line)
            }

            line = fileManager.readFactoredFileLine()
        }   while line != nil

    
        fileManager.closeNicePrimesFileForWrite()
        fileManager.closeFactoredFileForRead()
    }

    
    func factorPrimes(largestPrime: HLPrimeType) -> Int  {
        print( "\nHLPrime-  factorPrimes-  largestPrime: \(largestPrime)" )
        let startDate = Date()
        
        let errorCode = fileManager.openFactoredFileForAppend(with: factoredFileURL.path)
        if errorCode != 0   {
            return -1
        }
        fileManager.closeFactoredFileForAppend()

        var lastLine = fileManager.lastLine(forFile: factoredFileURL.path)!
        
        if let index = lastLine.index(of: "\t") {
            lastLine = String(lastLine.prefix(upTo: index))
        }
        
        let lastfactor = Int64(lastLine)!
 //       print( "HLPrime-  factorPrimes-  lastfactor: \(lastfactor)" )
        
        let primesErrorCode = fileManager.openPrimesFileForRead(with: primesFileURL.path)
        let factoredErrorCode = fileManager.openFactoredFileForAppend(with: factoredFileURL.path)
        assert( primesErrorCode == 0 )
        assert( factoredErrorCode == 0 )

        var nextP: HLPrimeType = 0
        repeat {    //  advance to the next prime to factor
            let line = fileManager.readPrimesFileLine()
   /*     print( "HLPrime-  factorPrimes-  line: \(line)" )
            if line == nil  {
                print( "HLPrime-  factorPrimes-  lastP: \(nextP)" )
            }   */
            (_, nextP) = parseLine(line: line!)
        } while nextP != lastfactor

        print( "HLPrime-  factorPrimes-  lastP: \(nextP)" )

        let lastPrimeLine = fileManager.lastLine(forFile: primesFileURL.path)!
        (lastN, lastP) = parseLine(line: lastPrimeLine)
        print( "factorPrimes-  Starting at-  lastN: \(lastN)    lastP: \(lastP)" )
       
        repeat {
            let line = fileManager.readPrimesFileLine()
            if line == nil  {   break   }   //  watch for end of file
            
            (_, nextP) = parseLine(line: line!)
            let factoredPrime = factor(prime: nextP)
            fileManager.appendFactoredLine(factoredPrime)
        } while nextP != min(largestPrime, lastP)

        fileManager.closeFactoredFileForAppend()
        fileManager.closePrimesFileForRead()

        factorFileLastLine = fileManager.lastLine(forFile: factoredFileURL.path)
        let deltaTime = startDate.timeIntervalSinceNow
        print( "HLPrime-  factorPrimes-  completed.  Time: \(-Int(deltaTime))" )
        
        makeNicePrimesFile()
        return 0
    }
    
    func makePrimes(largestPrime: HLPrimeType)  {
        print( "\nHLPrime-  makePrimes-  largestPrime: \(largestPrime)" )
        let startDate = Date()

         //  find out where we left off and continue from there
        let (lastN, lastP) = parseLine(line: primeFileLastLine!)
        print( "current makePrimes-  lastN: \(lastN)    lastP: \(lastP)" )

        var nextN = lastN + 1
        var nextP = lastP + 2

        fileManager.openPrimesFileForAppend(with: primesFileURL.path)

        while( largestPrime >= nextP ) {
            
            if isPrime(n: nextP)    {
                let output = String(format: "%d\t%ld\n", nextN, nextP)
                fileManager.appendPrimesLine(output)
                nextN += 1
            }
            
            nextP += 2

            //  yikes!  not working
            if !active   {
                break
            }
        }
        
        fileManager.closePrimesFileForAppend()
        
        primeFileLastLine = fileManager.lastLine(forFile: primesFileURL.path)
        let (newLastN, newLastP) = parseLine(line: primeFileLastLine!)
        print( "new makePrimes-  lastN: \(newLastN)    lastP: \(newLastP). " )
        let deltaTime = startDate.timeIntervalSinceNow
        print( "HLPrime-  makePrimes-  completed.  Time: \(-Int(deltaTime))" )
    }

 /*   func makePrimes(numberOfPrimes: HLPrimeType)  {
        print( "HLPrime-  makePrimes-  numberOfPrimes: \(numberOfPrimes)" )
        
        //  find out where we left off and continue from there
        let (lastN, lastP) = parseLine(line: fileManager.getLastLine()!)
        print( "lastN: \(lastN)    lastP: \(lastP)" )

        var n = Int(lastN)
        var nextPrime = Int64(lastP)
        setupBufFor(prime: nextPrime)
        print( "buf: \(buf)" )

        while( numberOfPrimes > n ) {
            
            nextPrime += 2
            if isPrime(n: nextPrime)    {
                n += 1
                let output = String(format: "%d\t%ld\n", n, nextPrime)
                fileManager.writeLine(output)
            }
        }
        
        fileManager.cleanup()
    }   */
    
    func parseLine(line: String) -> (index: Int, prime: Int64)  {
        let index = line.index(of: "\t")!
        let index2 = line.index(after: index)
        let lastN = line.prefix(upTo: index)
        let lastP = line.suffix(from: index2)
        return (Int(lastN)!, Int64(lastP)!)
    }
    
    init(primeFilePath: String, modCount: Int32)  {
        fileManager = HLFileManager(modCount)
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

