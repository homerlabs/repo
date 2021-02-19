//
//  String+Extension.swift
//  Prime Finder
//
//  Created by Matthew Homer on 8/13/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

import Cocoa
import Foundation

extension String    {

    func parseLine() -> (index: Int, prime: HLPrimeType)  {
        guard self.count > 2 else { return (0, 0) }
        var str = self
        if str.last == "\n" {
            str.removeLast()
        }

        if let index = str.firstIndex(of: "\t") {
            let index2 = str.index(after: index)
            guard let lastN = Int(str.prefix(upTo: index)) else { return (0, 0) }
            guard let lastP = HLPrimeType(str.suffix(from: index2)) else { return (0, 0) }
            return (lastN, lastP)
        }
        else    { return (0, 0) }
    }
}
