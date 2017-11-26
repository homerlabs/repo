//
//  String+Extension.swift
//  HLPrimes
//
//  Created by Matthew Homer on 11/6/17.
//  Copyright © 2017 HomerLabs. All rights reserved.
//

import Foundation


extension String    {
    func prefixInt64() -> Int64 {
        var tempString = self
        if let index = tempString.index(of: "\t") {
            tempString = String(tempString.prefix(upTo: index))
        }
        if let tempInt = Int64(tempString)  {
            return tempInt
        }
        else    {   //  not able to convert to Int
            return 0
        }
    }
    
    func parseLine() -> (index: Int, prime: Int64)  {
        if let index = self.index(of: "\t") {
            let index2 = self.index(after: index)
            let lastN = self.prefix(upTo: index)
            let lastP = self.suffix(from: index2)
            return (Int(lastN)!, Int64(lastP)!)
        }
        else    {
            return (0, 0)
        }
    }
}


extension Int    {
    func formatTime() -> String   {
        let hours = self / 3600
        let mintues = self / 60 - hours * 60
        let seconds = self - hours * 3600 - mintues * 60
        return String(format: "%02d:%02d:%02d", hours, mintues, seconds)
    }
}

