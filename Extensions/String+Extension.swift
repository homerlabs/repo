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
    

    func parseLine() -> (index: Int, prime: Int64)  {
        guard self.count > 2 else { return (0, 0) }
        var str = self
        if str.last == "\n" {
            str.removeLast()
        }

        if let index = str.firstIndex(of: "\t") {
            let index2 = str.index(after: index)
            let lastN = str.prefix(upTo: index)
            let lastP = str.suffix(from: index2)
            return (Int(lastN)!, Int64(lastP)!)
        }
        else    { return (0, 0) }
    }
}
