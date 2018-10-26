//
//  URL+Extension.swift
//  Disk Tester
//
//  Created by Matthew Homer on 10/15/18.
//  Copyright © 2018 Matthew Homer. All rights reserved.
//

import Foundation

extension URL    {
    func getBookmarkFor(key: String) -> URL?   {
        var url: URL? = nil
        
        if let data = UserDefaults.standard.data(forKey: key)  {
            do  {
                var isStale = false
                    url = try URL(resolvingBookmarkData: data, options: URL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                    let success = url!.startAccessingSecurityScopedResource()

                    if !success {
                        print("startAccessingSecurityScopedResource-  success: \(success)")
                    }
                } catch {
                    print("HLWarning:  Unable to optain security bookmark for key: \(key)!")
                }
        }
        return url
    }

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
