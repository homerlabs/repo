//
//  ViewController.swift
//  HLPlayer
//
//  Created by Matthew Homer on 10/26/18.
//  Copyright © 2018 Matthew Homer. All rights reserved.
//

import Cocoa
import AVFoundation
import AVKit

class ViewController: NSViewController {

    let HLVideoBookmarkKey  = "HLVideoBookmarkKey"
    let HLVideoURLKey       = "HLVideoURLKey"
    var videoURL: URL?
    var player: AVPlayer?

    @IBOutlet weak var playerView: AVPlayerView!
    @IBOutlet weak var videoPathButton: NSButton!

    @IBAction func setVideoPathAction(sender: NSButton) {
        if let url = getOpenFilePath(bookmarkKey: HLVideoBookmarkKey)  {
            videoURL = url
            videoPathButton.title = url.path
            UserDefaults.standard.set(url, forKey:HLVideoURLKey)
            
            let movie = AVMovie(url: url)
          print( "movie: \(movie)" )
          print( "movie.tracks: \(movie.tracks)" )
            print( "movie.url: \(String(describing: movie.url))" )
            print( "movie.data: \(String(describing: movie.data))" )
            print( "movie.isPlayable: \(movie.isPlayable)" )
            print( "movie.isReadable: \(movie.isReadable)" )
            print( "movie.duration.isValid: \(movie.duration.isValid)    movie.duration.seconds: \(movie.duration.seconds)" )
            print( "movie.allMediaSelections: \(movie.allMediaSelections)" )
            print( "movie.hasProtectedContent: \(movie.hasProtectedContent)" )

            
            let playerItem = AVPlayerItem(asset: movie)
            
  //          let playerItem = AVPlayerItem(url: url)
 //       print( "playerItem: \(String(describing: playerItem))" )
            player = AVPlayer(playerItem: playerItem)
            playerView.player = player
            player?.play()
        }
//        print( "videoURL: \(String(describing: videoURL?.path))" )
    }

   func getOpenFilePath(bookmarkKey: String) -> URL?     {
    
        var url: URL?
        let openPanel = NSOpenPanel();
        openPanel.allowedFileTypes = ["iso", "mp4", "mov"]
        openPanel.canChooseDirectories = true

        let i = openPanel.runModal();
        if(i == NSApplication.ModalResponse.OK){
            url = openPanel.url!
            openPanel.url!.setBookmarkFor(key: bookmarkKey)
        }
    
//    print( "getOpenFilePath: \(title),  Bookmark: \(bookmarkKey)  return: \(String(describing: url))" )
        return url
    }

    override func viewWillDisappear() {
        print( "viewWillDisappear)" )
        player?.pause()

        super.viewWillDisappear()
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

