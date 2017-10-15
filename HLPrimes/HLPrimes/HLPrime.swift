//
//  HLPrime.swift
//  HLPrimes
//
//  Created by Matthew Homer on 5/28/17.
//  Copyright © 2017 HomerLabs. All rights reserved.
//

import Foundation


class HLPrime: NSObject {

    let fileManager = HLFileManager(path: "/Users/mhomer/Desktop/Primes.txt")!
    
    func isPrime(n: Int) -> Bool    {
        return true
    }
    
    func makePrimes(numberOfPrimes: Int)  {
        print( "HLPrime-  makePrimes-  numberOfPrimes: \(numberOfPrimes)" )
        
        //  find out where we left off and continue from there
        let lastLine = fileManager.getLastLine()!
        let index = lastLine.index(of: "\t")!
        let index2 = lastLine.index(after: index)
        let lastN = lastLine.prefix(upTo: index)
        let lastP = lastLine.suffix(from: index2)
        print( "lastN: \(lastN)    lastP: '\(lastP)'" )

        var n = Int(lastN)!
        var nextPrime = Int(lastP)!
        
        while( numberOfPrimes > n ) {
            
            nextPrime += 2
            if isPrime(n: nextPrime)    {
                n += 1
                let output = String(format: "%d\t%ld\n", n, nextPrime)
                fileManager.writeLine(output)
            }
        }
        
        fileManager.cleanup()
    }
}
