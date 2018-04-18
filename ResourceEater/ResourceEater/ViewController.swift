//
//  ViewController.swift
//  ResourceEater
//
//  Created by Matthew Homer on 5/14/17.
//  Copyright © 2017 HomerLabs. All rights reserved.
//

import Cocoa

let mb = 1048576


class ViewController: NSViewController {

    @IBOutlet weak var runButton:       NSButton!
    @IBOutlet weak var ramButton:       NSButton!
    @IBOutlet weak var cpuButton:       NSButton!
    @IBOutlet weak var diskButton:      NSButton!
    @IBOutlet weak var ethernetButton:  NSButton!

    let ramSize = 500   //  megabytes
    let diskSize = 500  //  megabytes
    let kTimerInterval = 1.0
    var timer: Timer!
    var count = 0
    let filename = "ResourceEater"

    
    @IBAction func runAction(sender:NSButton)   {
        print( "ViewController-  runAction-  run state: \(runButton.state.rawValue)" )
        
        if runButton.state == .on  {
            runButton.title = "Stop"
            
            //  here is 'the loop' where resources are consumed
            timer = Timer.scheduledTimer(withTimeInterval: kTimerInterval, repeats: true) { timer in
            
                self.count += 1
            
                if self.ramButton.state == .on   {
                    self.leakMemory(megabytes: self.ramSize)
                }
           
                if self.diskButton.state == .on   {
                    self.writeToDisk(megabytes: 1)
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
        purgeFiles()
    }
    

    func writeToDisk(megabytes: Int)   {
 //       print( "ViewController-  writeToDisk" )
 
         do {
             let dir: URL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).last! as URL
             let fullFilename = filename + String(count) + ".txt"
             let url = dir.appendingPathComponent(fullFilename)
             try fullFilename.write(toFile: url.path, atomically: true, encoding: String.Encoding.utf8)
         }
         catch {
             print("Could not write to file")
         }
    }
    
    func purgeFiles()   {
        print( "Purge \(count) files" )

        let dir: URL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).last! as URL
        for index in 1...count  {
            let fullFilename = filename + String(index) + ".txt"
            let url = dir.appendingPathComponent(fullFilename)

            do  {
                try FileManager.default.removeItem(atPath: url.path)
            }
            catch   {
                 print("Could not purge file \(fullFilename)")
            }
        }
    }

    func leakMemory(megabytes: Int)   {
 //       print( "ViewController-  leakMemory" )
        ViewController.allocateMemoryOfSize( numberOfMegaBytes: megabytes )
    }


    static var buffer = [UInt8]()
    static func allocateMemoryOfSize(numberOfMegaBytes: Int) {
        let newBuffer = [UInt8](repeating: 0, count: numberOfMegaBytes * mb)
        buffer += newBuffer
        print("Allocating \(numberOfMegaBytes)MB of memory    Buf size: \(buffer.count/mb) MBs")
    }

    static func purgeBuffer() {
        print("Purge buffer of size: \(buffer.count/mb) MBs")
        buffer.removeAll()
    }
}

