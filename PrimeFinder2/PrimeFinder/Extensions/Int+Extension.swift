//
//  Int+Extension.swift
//  Prime Finder
//
//  Created by Matthew Homer on 8/13/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

//import Foundation

extension Int    {
    func formatTime() -> String   {
        let hours = self / 3600
        let mintues = self / 60 - hours * 60
        let seconds = self - hours * 3600 - mintues * 60
        return String(format: "%02d:%02d:%02d", hours, mintues, seconds)
    }
}

