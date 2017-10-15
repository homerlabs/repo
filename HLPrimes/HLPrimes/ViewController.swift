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
    var prime: HLPrime!

    @IBAction func buttonPushed(sender: NSButton) {
        print( "ViewController-  buttonPushed: \(sender.intValue)" )
        
        let value = runButton.state == .on
        if value {
            runButton.title = "Running"
            print( "terminalPrime: \(terminalPrime.intValue)  primeFilePath: \(primeFilePath.stringValue)" )

            prime = HLPrime(path: primeFilePath.stringValue)
            let lastPrime: HLPrimeType = Int64(terminalPrime.intValue)
            prime.makePrimes(largestPrime: lastPrime)
        }
        else    {
            runButton.title = "Stopped"
            runButton.isEnabled = false
            prime.active = value
        }
    }

    override var representedObject: Any? {
        didSet {
            print( "ViewController-  representedObject-  didSet: \(String(describing: representedObject))" )
        }
    }


}

