//
//  ViewController.swift
//  HLPrimes
//
//  Created by Matthew Homer on 5/28/17.
//  Copyright © 2017 HomerLabs. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var terminalPrime: NSTextField!
    @IBOutlet var primeFilePath: NSTextField!
    @IBOutlet var runButton: NSButton!
    var primeFinder: HLPrime!

    @IBAction func buttonPushed(sender: NSButton) {
        print( "ViewController-  buttonPushed: \(sender.intValue)" )
        
        let value = runButton.state == .on
        if value {
            runButton.title = "Running"
            print( "terminalPrime: \(terminalPrime.intValue)  primeFilePath: \(primeFilePath.stringValue)" )

            primeFinder = HLPrime(path: primeFilePath.stringValue)
            let lastPrime: HLPrimeType = Int64(terminalPrime.stringValue)!
            primeFinder.makePrimes(largestPrime: lastPrime)

            print( "    *********   makePrimes completed    *********" )
            runButton.title = "Completed"
            runButton.isEnabled = false
        }
        else    {
            runButton.title = "Stopped"
            runButton.isEnabled = false
            primeFinder.active = value
        }
    }
    
/*    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
            print( "ViewController-  representedObject-  didSet: \(String(describing: representedObject))" )
        }
    }   */
}

