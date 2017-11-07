//
//  String+Extension.swift
//  HLPrimes
//
//  Created by Matthew Homer on 11/6/17.
//  Copyright © 2017 HomerLabs. All rights reserved.
//

import Foundation


extension String    {

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
