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

    func getBookmark() -> URL?   {
        var url: URL? = nil
        
        if let data = UserDefaults.standard.data(forKey: self)  {
            do  {
                var isStale = false
                    url = try URL(resolvingBookmarkData: data, options: URL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                    let success = url!.startAccessingSecurityScopedResource()

                    if !success {
                        print("startAccessingSecurityScopedResource-  success: \(success)")
                    }
                } catch {
                    print("HLWarning:  Unable to optain security bookmark for key: \(self)!")
                }
        }
        return url
    }
    
    func getOpenFilePath(title: String) -> URL?     {
        
        var url: URL?
        let openPanel = NSOpenPanel();
        openPanel.canCreateDirectories = true;
        openPanel.allowedFileTypes = ["txt"];
        openPanel.showsTagField = false;
        openPanel.prompt = "Open";
        openPanel.message = title;
        
        let i = openPanel.runModal();
        if(i == NSApplication.ModalResponse.OK) {
            url = openPanel.url
        }
        
        print( "getOpenFilePath: \(title),  Bookmark: \(self)  return: \(String(describing: url))" )
        return url
    }

    func getSaveFilePath(title: String, message: String) -> URL?     {
        
        var url: URL?
        let savePanel = NSSavePanel();
        savePanel.canCreateDirectories = true;
        savePanel.title = title;
        savePanel.nameFieldStringValue = self;
        savePanel.showsTagField = false;
        savePanel.prompt = "Create";
        savePanel.message = message;
        savePanel.nameFieldLabel = "Save As:";
        savePanel.allowedFileTypes = ["txt"];
        
        let i = savePanel.runModal();
        if(i == NSApplication.ModalResponse.OK){
            url = savePanel.url
        }
        
        //      print( "getSaveFilePath: \(title),return: \(String(describing: url))" )
        return url
    }
    

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
