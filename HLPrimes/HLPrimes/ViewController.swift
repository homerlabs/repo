//
//  ViewController.swift
//  HLPrimes
//
//  Created by Matthew Homer on 5/28/17.
//  Copyright © 2017 HomerLabs. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSControlTextEditingDelegate {

    @IBOutlet var primeFilePathTextField: NSTextField!
    @IBOutlet var factorFilePathTextField: NSTextField!
    @IBOutlet var lastLinePrimeTextField: NSTextField!
    @IBOutlet var lastLineFactorTextField: NSTextField!
    @IBOutlet var terminalPrimeTextField: NSTextField!
    @IBOutlet var runButton: NSButton!
    
    var primeFinder: HLPrime!

    @IBAction func primeStartAction(sender: NSButton) {
        print( "ViewController-  primeStartAction: \(sender.intValue)" )
        
        let value = runButton.state == .on
        if value {
            runButton.title = "Running"
            print( "terminalPrime: \(terminalPrimeTextField.intValue)  primeFilePath: \(primeFilePathTextField.stringValue)" )

     //       primeFinder = HLPrime(path: primeFilePathTextField.stringValue)
            let lastPrime: HLPrimeType = Int64(terminalPrimeTextField.stringValue)!
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
    
    @IBAction func factorStartAction(sender: NSButton) {
        print( "ViewController-  factorStartAction: \(sender.intValue)" )
    }
    
	func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool    {
        print( "ViewController-  textShouldEndEditing-  control: \(control)" )
        
        if control == primeFilePathTextField    {
            if let lastLine = primeFinder.lastLineFor(path: primeFilePathTextField.stringValue) {
                lastLinePrimeTextField.stringValue = lastLine
            }
            else    {
                lastLinePrimeTextField.stringValue = "FILE NOT FOUND"
            }
        }
        
        else if control == factorFilePathTextField  {
            if let lastLine = primeFinder.lastLineFor(path: factorFilePathTextField.stringValue) {
                lastLineFactorTextField.stringValue = lastLine
            }
            else    {
                lastLineFactorTextField.stringValue = "FILE NOT FOUND"
            }
        }
        
        else    {   assert( false )     }
        
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        lastLinePrimeTextField.stringValue = "?"
        lastLineFactorTextField.stringValue = "?"
        
        primeFinder = HLPrime(primeFilePath: primeFilePathTextField.stringValue, factorFilePath: factorFilePathTextField.stringValue)
        
        if let primeLastLine = primeFinder.primeFileLastLine {
            lastLinePrimeTextField.stringValue = primeLastLine
        }
        
        if let factorLastLine = primeFinder.factorFileLastLine {
            lastLineFactorTextField.stringValue = factorLastLine
        }
    }

/*    override var representedObject: Any? {
        didSet {
            print( "ViewController-  representedObject-  didSet: \(String(describing: representedObject))" )
        }
    }   */
}

