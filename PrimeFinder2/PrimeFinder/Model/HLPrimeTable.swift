//
//  HLPrimeTable.swift
//  Prime Finder
//
//  Created by Matthew Homer on 8/13/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

import Foundation

public class HLPrimeTable {

    var pTable: [HLPrimeType] = [2, 3]

    public func createPTable(maxPrime: HLPrimeType) -> [HLPrimeType] {
        var lastPrime: HLPrimeType = pTable.last!
        var lastPrimeCandidate = lastPrime + 2
        var loopCount: HLPrimeType = 0

        //  must build up table in chunks
        while lastPrimeCandidate < maxPrime {
            let highestPossiblePrimeCandidate = lastPrime * lastPrime
            loopCount = (highestPossiblePrimeCandidate - lastPrime) / 2    //  we don't check even numbers for prime
            
            for _ in 0..<loopCount {
                if isPrime(lastPrimeCandidate) {
                    pTable.append(lastPrimeCandidate)
                }
                
                lastPrimeCandidate += 2
           }
            
            lastPrime = pTable.last!
       }

        return pTable
    }
    
    func isPrime(_ value: HLPrimeType) -> Bool    {
        var candidateIsPrime = true
        let maxTestPrime = Int64(sqrt(Double(value)))
        
        var index = 1   //  we don't try the value in [0] == 2
//        var index = 0   //  we do try the value in [0] == 2
        var testPrime = pTable[index]
        while testPrime <= maxTestPrime {
            let q_r = lldiv(value, testPrime)
            if q_r.rem == 0 {
                candidateIsPrime = false
                break
            }

            index += 1
            guard index < pTable.count else { return false }    //  don't go past the end of the pTable
            testPrime = pTable[index]
        }
        
//        print( "HLPrime-  isPrime: \(value)   isPrime: \(isPrime)" )
        return candidateIsPrime
    }

}
