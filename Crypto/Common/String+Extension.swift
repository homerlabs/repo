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
    
    func getBookmarkFor(key: String) -> URL?   {
        var url: URL? = nil
        
        if let data = UserDefaults.standard.data(forKey: key)  {
            do  {
                var isStale = false
                    url = try URL(resolvingBookmarkData: data, options: URL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                    let success = url!.startAccessingSecurityScopedResource()
                    print("startAccessingSecurityScopedResource-  success: \(success)")
                } catch {
                    print("Warning:  Unable to optain security bookmark for key: \(key)!")
                }
        }
        return url
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


extension URL    {
    func setBookmarkFor(key: String) {
        do  {
            let data = try self.bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope,
                                    includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(data, forKey:key)
        }   catch   {
            print("Warning:  Unable to create security bookmark for key: \(key)!")
        }
    }
}


