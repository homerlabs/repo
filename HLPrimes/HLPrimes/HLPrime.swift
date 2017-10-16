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
    let bufSize = 100
    var buf: [HLPrimeType] = []
    var largestBufPrime: HLPrimeType = 0
    var active = true
    
    var lastN: Int = 0
    var lastP: HLPrimeType = 0

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
    
    func setupBufFor(prime: HLPrimeType)   {
        fileManager.openForRead()
        let largestTestPrime = Int(sqrt(Double(prime)))

        repeat  {
            if let nextLine = fileManager.readLine()    {
                let (_, lastP) = parseLine(line: nextLine)
                let prime = Int64(lastP)
                buf.append(prime)
                largestBufPrime = prime
            }
            else    {
                break
            }
        } while largestBufPrime < largestTestPrime
    }
    
    func getPrimeInBufAt(index: Int) -> HLPrimeType   {
        while index >= buf.count   {
            if let nextLine = fileManager.readLine()    {
                let (_, lastP) = parseLine(line: nextLine)
                let prime = Int64(lastP)
                buf.append(prime)
                largestBufPrime = prime
            }
            else    {
                return 0
            }
        }
        return buf[index]
    }
    
    func factorPrimes(largestPrime: HLPrimeType)  {
        print( "HLPrime-  factorPrimes-  largestPrime: \(largestPrime)" )
        
        var n = lastN
        var nextPrime = lastP + 2
        setupBufFor(prime: largestPrime)
 //       print( "buf: \(buf)" )

        while( largestPrime > nextPrime ) {
            
            if isPrime(n: nextPrime)    {
                n += 1
                let output = String(format: "%d\t%ld\n", n, nextPrime)
                fileManager.writeLine(output)
            }
            
            nextPrime += 2

            //  yikes!  not working
            if !active   {
                break
            }
        }
        
        fileManager.cleanup()
    }
    
    func makePrimes(largestPrime: HLPrimeType)  {
        print( "HLPrime-  makePrimes-  largestPrime: \(largestPrime)" )
        
        var n = lastN
        var nextPrime = lastP + 2
        setupBufFor(prime: largestPrime)
 //       print( "buf: \(buf)" )

        while( largestPrime > nextPrime ) {
            
            if isPrime(n: nextPrime)    {
                n += 1
                let output = String(format: "%d\t%ld\n", n, nextPrime)
                fileManager.writeLine(output)
            }
            
            nextPrime += 2

            //  yikes!  not working
            if !active   {
                break
            }
        }
        
        fileManager.cleanup()
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
    
    init(path: String)  {
        fileManager = HLFileManager(path: path)!
        super.init()
        
        (lastN, lastP) = parseLine(line: fileManager.getLastLine()!)
        print( "HLPrime.init-  lastN: \(lastN)    lastP: \(lastP)" )
    }
}

