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
    var sourceURL: URL?
    var destinationURL: URL?

    @IBOutlet weak var sourcePathButton: NSButton!
    @IBOutlet weak var destinationPathButton: NSButton!

    @IBAction func setSourcePathAction(sender: NSButton) {
        print( "setSourcePathAction" )
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
            savePanel.url!.setBookmarkFor(key: HLDestinationFilePathKey)
            sender.title = savePanel.url!.path
            UserDefaults.standard.set(savePanel.url!.path, forKey:HLDestinationFilePathKey)
            destinationURL = savePanel.url!.path.getBookmarkFor(key: HLDestinationFilePathKey)
       }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        print( "ViewController-  viewDidDisappear" )
        exit(0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

