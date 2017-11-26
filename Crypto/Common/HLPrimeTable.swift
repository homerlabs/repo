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

    let fileManager: HLFileManager = HLFileManager.shared()
    var primesFileURL: URL!


    init?(primeFileURL: URL, largestPrime: HLPrimeType)  {
        self.primesFileURL = primeFileURL
        
        print( "HLPrimeTable-  init?-  primeFileURL: \(primeFileURL.path)    largestPrime: \(largestPrime)" )
        
        if self.fileManager.openPrimesFileForRead(with: self.primesFileURL.path) == 0  {
            var lastP: HLPrimeType = 0
            
            if let nextLine = self.fileManager.readPrimesFileLine()    {
                (_, lastP) = nextLine.parseLine()
            }
            else    {   return nil  }   //  file present but empty

            while lastP <= largestPrime {
                self.buf.append(lastP)

                if let nextLine = self.fileManager.readPrimesFileLine()    {
                    (_, lastP) = nextLine.parseLine()
                }
                else    {   break   }
            }
            
            self.fileManager.closePrimesFileForRead()
         
            super.init()
       }
        
        //  was not able to open the prime file
        else    {   return nil  }
    }
}
