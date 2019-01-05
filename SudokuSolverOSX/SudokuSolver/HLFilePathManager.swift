//
//  HLFilePathManager.swift
//  Sudoku Solver
//
//  Created by Matthew Homer on 1/5/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

import Cocoa

class HLFilePathManager: NSObject {

   func getOpenFilePath(title: String, bookmarkKey: String) -> String?     {
    
        var path: String?
        let openPanel = NSOpenPanel();
        openPanel.canCreateDirectories = true;
        openPanel.allowedFileTypes = ["txt"];
        openPanel.showsTagField = false;
        openPanel.prompt = "Open";
        openPanel.message = title;

        let i = openPanel.runModal();
        if(i == NSApplication.ModalResponse.OK){
            path = openPanel.url!.path
     //       openPanel.url!.setBookmarkFor(key: bookmarkKey)
        }
    
    print( "getOpenFilePath: \(title),  Bookmark: \(bookmarkKey)  return: \(String(describing: path))" )
        return path
    }

   func getSaveFilePath(title: String, fileName: String, bookmarkKey: String) -> String?     {
    
        var path: String?
        let savePanel = NSSavePanel();
        savePanel.canCreateDirectories = true;
        savePanel.title = "PrimeFinder Save Panel";
        savePanel.nameFieldStringValue = fileName;
        savePanel.showsTagField = false;
        savePanel.prompt = "Create";
        savePanel.message = title;
        savePanel.nameFieldLabel = "Save As:";
        savePanel.allowedFileTypes = ["txt"];

        let i = savePanel.runModal();
        if(i == NSApplication.ModalResponse.OK){
            path = savePanel.url!.path
  //          savePanel.url!.setBookmarkFor(key: bookmarkKey)
        }
    
    print( "getSaveFilePath: \(title),  Bookmark: \(bookmarkKey)  return: \(String(describing: path))" )
        return path
    }
}
