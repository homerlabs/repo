//
//  HLPrimeTable.swift
//  RSATool
//
//  Created by Matthew Homer on 11/7/17.
//  Copyright © 2017 Matthew Homer. All rights reserved.
//

import Cocoa

class HLPrimeTable: NSObject {

    var buf: [HLPrimeType] = []

    let fileManager: HLFileManager = HLFileManager(1000000)
    var primesFileURL: URL!

    var lastN: Int = 0
    var lastP: HLPrimeType = 0
    var largestBufPrime: HLPrimeType


    init?(primeFileURL: URL, largestPrime: HLPrimeType)  {
        largestBufPrime = largestPrime
        self.primesFileURL = primeFileURL
        
        super.init()
        print( "HLPrimeTable-  primeFileURL: \(primeFileURL)    largestPrime: \(largestPrime)" )
        
        if self.fileManager.openPrimesFileForRead(with: self.primesFileURL.path) == 0  {
            repeat  {
                if let nextLine = self.fileManager.readPrimesFileLine()    {
                    (self.lastN, self.lastP) = nextLine.parseLine()
                    self.buf.append(self.lastP)
                }
                else    {
                    break
                }
            } while self.lastP < self.largestBufPrime
            
            self.largestBufPrime = self.lastP
            self.fileManager.closePrimesFileForRead()
        }
        
        //  was not able to open the prime file
        else    {   return nil  }
    }
}
