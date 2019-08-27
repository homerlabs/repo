//
//  ViewController+Extension.swift
//  
//
//  Created by Matthew Homer on 8/18/19.
//

import Cocoa
import Foundation

//  URL Bookmark get and set helpers
extension ViewController {

    func displayAlert(title: String, message: String)     {
        let a: NSAlert = NSAlert()
        a.messageText = title
        a.informativeText = message
        a.addButton(withTitle: "OK")
        a.alertStyle = NSAlert.Style.warning

        a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse: NSApplication.ModalResponse) -> Void in
            if(modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn){
                print("Bad data value.")
            }
        })
    }

    func getOpenFilePath(title: String, bookmarkKey: String) -> URL?     {
        
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
        
        print( "getOpenFilePath: \(title),  Bookmark: \(bookmarkKey)  return: \(String(describing: url))" )
        return url
    }
    
    func getSaveFilePath(title: String, message: String, fileName: String) -> URL?     {
        
        var url: URL?
        let savePanel = NSSavePanel();
        savePanel.canCreateDirectories = true;
        savePanel.title = title;
        savePanel.nameFieldStringValue = fileName;
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
    
    func getBookmarkFor(key: String) -> URL?   {
        var url: URL?
        if let data = UserDefaults.standard.data(forKey: key)  {
            do  {
                var isStale = false
                    url = try URL(resolvingBookmarkData: data, options: URL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                    let success = url!.startAccessingSecurityScopedResource()

                    if !success {
                        print("startAccessingSecurityScopedResource-  success: \(success)")
                    }
                } catch {
           //         print("Warning:  Unable to optain security bookmark for key: \(key) with error: \(error)!")
                }
        }
        
 //       print("getBookmarkFor-  key: \(key)  url: \(String(describing: url))")
        return url
    }

    func setBookmarkFor(key: String, url: URL) {
  //      print("setBookmarkFor-  key: \(key)  url: \(url)")
        do  {
            let data = try url.bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(data, forKey:key)
        }   catch   {
            print("Warning:  Unable to create security bookmark for key: \(key) with error: \(error)!")
        }
    }
}
