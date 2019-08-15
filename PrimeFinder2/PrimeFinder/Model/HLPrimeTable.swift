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
        let maxPTablePrimeRequired = Int64(sqrt(Double(maxPrime)))
        var primeCandidate = pTable.last! + 2   //  start after the last known prime (3)
        let startDate = Date()

        while primeCandidate < maxPTablePrimeRequired {
            
                if isPrime(primeCandidate) {
                    pTable.append(primeCandidate)
                }
                primeCandidate += 2
       }

        print(String(format: "HLPrimeTable-  createPTable completed in %0.2f seconds and has \(pTable.count) values", -Double(startDate.timeIntervalSinceNow)))
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
            guard index < pTable.count else {
                return true  //  if we get here, we have exhausted the pTable
            }
            testPrime = pTable[index]
        }
        
//        print( "HLPrime-  isPrime: \(value)   isPrime: \(isPrime)" )
        return candidateIsPrime
    }

}
