//
//  ViewController.swift
//  ResourceEater
//
//  Created by Matthew Homer on 5/14/17.
//  Copyright © 2017 HomerLabs. All rights reserved.
//

import Cocoa

let mb = 1048576


import Foundation

enum FileWriteError: Error {
    case directoryDoesntExist
    case convertToDataIssue
}

protocol FileWriter {
    func write(_ text: String, filename: String) throws
}

extension FileWriter {
//    var fileName: String { return "ResourceEater.txt" }

    func write(_ text: String, filename: String) throws {
        guard let dir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            throw FileWriteError.directoryDoesntExist
        }

        let encoding = String.Encoding.utf8

        guard let data = text.data(using: encoding) else {
            throw FileWriteError.convertToDataIssue
        }

        let fileUrl = dir.appendingPathComponent(filename)

        if let fileHandle = FileHandle(forWritingAtPath: fileUrl.path) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
        } else {
            try text.write(to: fileUrl, atomically: false, encoding: encoding)
        }
    }
}


class ViewController: NSViewController, FileWriter {
    @IBOutlet weak var runButton:       NSButton!
    @IBOutlet weak var ramButton:       NSButton!
    @IBOutlet weak var cpuButton:       NSButton!
    @IBOutlet weak var diskButton:      NSButton!

    let ramSize = 500   //  megabytes
    let diskSize = 500  //  megabytes
    let kTimerInterval = 1.0
    var timer: Timer!
    var count = 0
    let filename = "ResourceEater.txt"
    var processShouldTerminate = false
    var outputText = ""
    let HLDefaultsKey = "HLDefaultsKey"
    let weightRAM = 1
    let weightCPU = 2
    let weightDisk = 4

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
                    self.writeToDisk(numberOfKBytes: 1024)
                }
           
                if self.cpuButton.state == .on   {
                    self.spawnProcess(processCount: 100)
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
        
        processShouldTerminate = true
        ViewController.purgeBuffer()
        purgeFile()
    }

    func spawnProcess(processCount: Int)   {
 //       print( "ViewController-  spawnProcess" )
 
        processShouldTerminate = false
        var counter = 0.0

        DispatchQueue.global(qos: .userInitiated).async {
            while  !self.processShouldTerminate   {
                counter += 0.001
            }

            DispatchQueue.main.async {
                print( "spawnProcess terminates" )
            }
        }
    }
    

    func writeToDisk(numberOfKBytes: Int)   {
 //       print( "ViewController-  writeToDisk" )

         do {
            for _ in 0..<numberOfKBytes {
                try write(outputText, filename: filename)
            }
         }
         catch {
             print("Could not write to file")
         }
    }
    
    func purgeFile()   {

        let dir: URL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).last! as URL
        let url = dir.appendingPathComponent(filename)
        
        if FileManager.default.fileExists(atPath: url.path)     {
            do  {
                try FileManager.default.removeItem(atPath: url.path)
            }
            catch   {
                 print("Could not purge file \(filename)")
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
    
    override func viewDidLoad() {
        let text = "0" + String(repeating: "1", count: 1021) + "2\n"
        for _ in 0..<1 {
            outputText += text
        }
        
        let value = UserDefaults.standard.integer(forKey: HLDefaultsKey)
        let ram = value & weightRAM
        let cpu = value & weightCPU
        let disk = value & weightDisk
        
        ramButton.state = NSControl.StateValue(rawValue: ram)
        cpuButton.state = NSControl.StateValue(rawValue: cpu)
        diskButton.state = NSControl.StateValue(rawValue: disk)

    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        purgeAction(sender: runButton)
        
        var value = 0
        if ramButton.state == .on   {
            value += weightRAM
        }
        
        if cpuButton.state == .on   {
            value += weightCPU
        }
        
        if diskButton.state == .on   {
            value += weightDisk
        }
        UserDefaults.standard.set(value, forKey:HLDefaultsKey)

        exit(0)
    }
}

