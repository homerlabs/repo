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

    let HLSourceFilePathKey      = "SourcePathKey"
    let HLDestinationFilePathKey = "DestinationPathKey"
    let HLSourceBookmarkKey      = "SourceBookmarkKey"
    let HLDestinationBookmarkKey = "DestinationBookmarkKey"
    var sourceURL: URL?
    var destinationURL: URL?

    @IBOutlet weak var sourcePathButton: NSButton!
    @IBOutlet weak var destinationPathButton: NSButton!

    @IBAction func setSourcePathAction(sender: NSButton) {
        let savePanel = NSSavePanel();
        savePanel.canCreateDirectories = true;
        savePanel.title = "Set test file path";
        savePanel.nameFieldStringValue = "HLBigTestFile";
        savePanel.showsTagField = false;
        savePanel.prompt = "Create";

        let i = savePanel.runModal();
        if(i == NSApplication.ModalResponse.OK){
            savePanel.url!.setBookmarkFor(key: HLSourceBookmarkKey)
            sender.title = savePanel.url!.path
            UserDefaults.standard.set(savePanel.url!.path, forKey:HLSourceFilePathKey)
            UserDefaults.standard.synchronize()
           sourceURL = savePanel.url!.path.getBookmarkFor(key: HLSourceBookmarkKey)
       }
        print( "sourceURL: \(String(describing: sourceURL))" )
    }

    @IBAction func setDestinationPathAction(sender: NSButton) {
        let savePanel = NSSavePanel();
        savePanel.canCreateDirectories = true;
        savePanel.title = "Set test file path";
        savePanel.nameFieldStringValue = "HLBigTestFile";
        savePanel.showsTagField = false;
        savePanel.prompt = "Create";

        let i = savePanel.runModal();
        if(i == NSApplication.ModalResponse.OK){
            savePanel.url!.setBookmarkFor(key: HLDestinationBookmarkKey)
            sender.title = savePanel.url!.path
            UserDefaults.standard.set(savePanel.url!.path, forKey:HLDestinationFilePathKey)
            UserDefaults.standard.synchronize()
            destinationURL = savePanel.url!.path.getBookmarkFor(key: HLDestinationBookmarkKey)
       }
        print( "destinationURL: \(String(describing: destinationURL))" )
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        print( "ViewController-  viewDidDisappear" )
        sourceURL?.stopAccessingSecurityScopedResource()
        destinationURL?.stopAccessingSecurityScopedResource()
        exit(0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let primeFilePath = UserDefaults.standard.string(forKey: HLSourceFilePathKey)  {
            sourceURL = primeFilePath.getBookmarkFor(key: HLSourceFilePathKey)
            if sourceURL != nil {
                sourcePathButton.title = sourceURL!.path
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

