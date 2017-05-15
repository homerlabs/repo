//
//  ViewController.swift
//  ResourceEater
//
//  Created by Matthew Homer on 5/14/17.
//  Copyright © 2017 HomerLabs. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var runButton: NSButton!
    
    let kTimerInterval = 0.5
    var running = false
    var timer: Timer!
    
    
    @IBAction func buttonAction(sender:Any)   {
        print( "ViewController-  buttonAction" )
        
        running = !running
        
        if running  {
            runButton.title = "Stop"
            timer = Timer.scheduledTimer(withTimeInterval: kTimerInterval, repeats: true) { timer in

                self.leakMemory()
            }
        }
        else    {
            runButton.title = "Start"
            timer.invalidate()
        }
    }
    
    
    func leakMemory()   {
 //       print( "ViewController-  leakMemory" )
        ViewController.allocateMemoryOfSize( numberOfMegaBytes: 500 )
    }


    static var buffer = [UInt8]()
    static func allocateMemoryOfSize(numberOfMegaBytes: Int) {
        print("Allocating \(numberOfMegaBytes)MB of memory")
        let mb = 1048576
        let newBuffer = [UInt8](repeating: 0, count: numberOfMegaBytes * mb)
        buffer += newBuffer
    }
}

