//
//  URL+Extension.swift
//  Disk Tester
//
//  Created by Matthew Homer on 10/15/18.
//  Copyright © 2018 Matthew Homer. All rights reserved.
//

import Foundation

extension URL    {
    func setBookmarkFor(key: String) {
        do  {
            let data = try self.bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope,
                                    includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(data, forKey:key)
        }   catch   {
            print("HLWarning:  Unable to create security bookmark for key: \(key)!")
        }
    }
}
