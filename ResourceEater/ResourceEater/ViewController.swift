//
//  ViewController.swift
//  ResourceEater
//
//  Created by Matthew Homer on 5/14/17.
//  Copyright © 2017 HomerLabs. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var runButton:       NSButton!
    @IBOutlet weak var ramButton:       NSButton!
    @IBOutlet weak var cpuButton:       NSButton!
    @IBOutlet weak var diskButton:      NSButton!
    @IBOutlet weak var ethernetButton:  NSButton!

    let ramSize = 500   //  megabytes
    let diskSize = 500  //  megabytes
    let kTimerInterval = 1.0
//    var running = false
    var timer: Timer!
    
    
    @IBAction func runAction(sender:NSButton)   {
        print( "ViewController-  runAction-  run state: \(runButton.state)" )
        
 //       running = !running
        
        if runButton.state == .on  {
            runButton.title = "Stop"
            timer = Timer.scheduledTimer(withTimeInterval: kTimerInterval, repeats: true) { timer in
            
                if self.ramButton.state == .on   {
                    self.leakMemory(megabytes: self.ramSize)
                }
            }
        }
        else    {
            runButton.title = "Start"
            timer.invalidate()
        }
    }
    
    @IBAction func purgeAction(sender:NSButton)   {
        print( "ViewController-  purgeAction" )
        
        ViewController.purgeBuffer()
        
    }
    

    func leakMemory(megabytes: Int)   {
 //       print( "ViewController-  leakMemory" )
        ViewController.allocateMemoryOfSize( numberOfMegaBytes: megabytes )
    }


    static var buffer = [UInt8]()
    static func allocateMemoryOfSize(numberOfMegaBytes: Int) {
        print("Allocating \(numberOfMegaBytes)MB of memory")
        let mb = 1048576
        let newBuffer = [UInt8](repeating: 0, count: numberOfMegaBytes * mb)
        buffer += newBuffer
    }

    static func purgeBuffer() {
        print("Purge buffer of size: \(buffer.count)")
        buffer.removeAll()
    }
}

