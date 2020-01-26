//
//  HLPrime+Extension.swift
//  Prime Finder
//
//  Created by Matthew Homer on 8/25/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

import Foundation

extension HLPrime {
    
       public func findPrimes0(maxPrime: HLPrimeType, completion: @escaping HLCompletionClosure) {
           print( "\nHLPrime-  findPrimes-  maxPrime: \(maxPrime)" )

           DispatchQueue.global(qos: .userInitiated).async { [weak self] in
               guard let self = self else { return }
               
               self.pTable = self.createPTable(maxPrime: maxPrime)
               (self.lastN, self.lastP) = (3, 5)   //  this is our starting point
               
               let error = self.fileManager.createPrimesFileForAppend(with: self.primesFileURL.path)
               assert(error==0, "createPrimesFileForAppend failed with error: \(error)")
               
               self.lastLine = "2\t3\n"
           
    //           print( "HLPrime-  findPrimes-  entering main loop ..." )
               self.startDate = Date()  //  don't count the time to create pTable


               //***********************************************************************************
               while( maxPrime >= self.lastP && self.okToRun ) {
                   if self.isPrime(self.lastP)    {
                       self.lastLine = String(format: "%d\t%ld\n", self.lastN, self.lastP)
                       self.fileManager.appendPrimesLine(self.lastLine)
                       self.lastN += 1
                   }
                   self.lastP += 2
               }
               //***********************************************************************************


               self.timeInSeconds = -Int(self.startDate.timeIntervalSinceNow)
               self.fileManager.closePrimesFileForAppend()
               self.pTable.removeAll()
               
               DispatchQueue.main.async { [weak self] in
                   guard let self = self else { return }
                   let (newLastN, newLastP) = self.lastLine.parseLine()
                   print( "findPrimes-  final lastN: \(newLastN)    lastP: \(newLastP)" )
                   completion(self.lastLine)
               }
           }
       }
}
