//
//  ViewController.swift
//  Disk Tester
//
//  Created by Matthew Homer on 10/15/18.
//  Copyright © 2018 Matthew Homer. All rights reserved.
//

import Cocoa
import Automator

class ViewController: NSViewController {

    let HLSourceBookmarkKey      = "SourceBookmarkKey"
    let HLDestinationBookmarkKey = "DestinationBookmarkKey"
    let filename = "HLBigTestFile"
    var sourceURL: URL?
    var destinationURL: URL?

    @IBOutlet weak var sourcePathButton: NSButton!
    @IBOutlet weak var destinationPathButton: NSButton!

    @IBAction func setSourcePathAction(sender: NSButton) {
        let savePanel = NSSavePanel();
        savePanel.canCreateDirectories = true;
        savePanel.title = "Set source test file path";
        savePanel.nameFieldStringValue = "HLBigTestFile";
        savePanel.showsTagField = false;
        savePanel.prompt = "Create";

        let i = savePanel.runModal();
        if(i == NSApplication.ModalResponse.OK){
            sourceURL = savePanel.url
            sourceURL!.setBookmarkFor(key: HLSourceBookmarkKey)
            UserDefaults.standard.synchronize()
            sourcePathButton.title = sourceURL!.path
       }
        print( "sourceURL: \(String(describing: sourceURL))" )
        createBigFile()
    }

    @IBAction func setDestinationPathAction(sender: NSButton) {
        let savePanel = NSSavePanel();
        savePanel.canCreateDirectories = true;
        savePanel.title = "Set destination test file path";
        savePanel.nameFieldStringValue = "HLBigTestFile";
        savePanel.showsTagField = false;
        savePanel.prompt = "Create";

        let i = savePanel.runModal();
        if(i == NSApplication.ModalResponse.OK){
            destinationURL = savePanel.url
            destinationURL!.setBookmarkFor(key: HLDestinationBookmarkKey)
            UserDefaults.standard.synchronize()
            destinationPathButton.title = destinationURL!.path
       }
        print( "destinationURL: \(String(describing: destinationURL))" )
    }
    
    @IBAction func runTestAction(sender: NSButton) {
        guard sourceURL != nil else {
            print( "Serious Error:  Source URL is NIL" )
            return
        }
        
        guard destinationURL != nil else {
            print( "Serious Error:  Destination URL is NIL" )
            return
        }
        
        sourceURL!.copyFileTo(url: destinationURL!)
        print( "runTestAction" )
    }
    
    func createBigFile()    {
        guard sourceURL != nil else {
            print( "Serious Error:  Source URL is NIL" )
            return
        }

        let string100: String = "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
        let data = Data(base64Encoded: string100)
        let success = FileManager.default.createFile(atPath: sourceURL!.path, contents: data, attributes: nil)
        print( "createBigFile-  success: \(success)" )
    }

    func deleteFile(url: URL)   {
        do  {
                try FileManager.default.removeItem(at: url)
            } catch {
                print("Warning:  Unable to delete file: \(url)!")
            }
    }

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
                    print("Warning:  Unable to optain security bookmark for key: \(key)!")
                }
        }
        return url
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        print( "ViewController-  viewDidDisappear" )
        
        //  remove any created files if present
        if let url = sourceURL  {
            deleteFile(url: url)
        }
        if let url = destinationURL  {
            deleteFile(url: url)
        }
        
        sourceURL?.stopAccessingSecurityScopedResource()
        destinationURL?.stopAccessingSecurityScopedResource()
        exit(0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sourceURL = getBookmarkFor(key: HLSourceBookmarkKey)
        destinationURL = getBookmarkFor(key: HLDestinationBookmarkKey)

        if let url = sourceURL  {
            sourcePathButton.title = url.path
        }

        if let url = destinationURL  {
            destinationPathButton.title = url.path
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

