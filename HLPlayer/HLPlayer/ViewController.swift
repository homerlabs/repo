//
//  ViewController.swift
//  HLPlayer
//
//  Created by Matthew Homer on 10/26/18.
//  Copyright © 2018 Matthew Homer. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    let HLVideoBookmarkKey  = "HLVideoBookmarkKey"
    let HLVideoURLKey       = "HLVideoURLKey"
    var videoURL: URL?

    @IBOutlet weak var videoPathButton: NSButton!

    @IBAction func setVideoPathAction(sender: NSButton) {
        if let url = getOpenFilePath(bookmarkKey: HLVideoBookmarkKey)  {
            videoURL = url
            videoPathButton.title = url.path
            UserDefaults.standard.set(url, forKey:HLVideoURLKey)
        }
        print( "videoURL: \(String(describing: videoURL?.path))" )
    }

   func getOpenFilePath(bookmarkKey: String) -> URL?     {
    
        var url: URL?
        let openPanel = NSOpenPanel();
        openPanel.allowedFileTypes = ["iso"];

        let i = openPanel.runModal();
        if(i == NSApplication.ModalResponse.OK){
            url = openPanel.url!
            openPanel.url!.setBookmarkFor(key: bookmarkKey)
        }
    
//    print( "getOpenFilePath: \(title),  Bookmark: \(bookmarkKey)  return: \(String(describing: url))" )
        return url
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

