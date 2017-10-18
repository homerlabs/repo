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
    @IBOutlet var modCountTextField: NSTextField!

    @IBOutlet var primeStartButton: NSButton!
    @IBOutlet var factorStartButton: NSButton!

    var primeFinder: HLPrime!
    let HLDefaultPrimeFilePathKey = "PrimeFilePathKey"
    let HLDefaultTerminalPrimeKey = "TerminalPrimeKey"
    let HLDefaultModCountKey = "ModCountKey"

    let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
    var errorCode = 0

    @IBAction func primeStartAction(sender: NSButton) {
        
        let value = primeStartButton.state == .on
        if value {
            primeStartButton.title = "Running"
            let lastPrime: HLPrimeType = Int64(terminalPrimeTextField.stringValue)!

            errorCode = primeFinder.loadBufFor(prime: lastPrime)
            if errorCode != 0   {   //  serious error
                //  alert user with some kind of hint?
                print( "    *********   Serious Error-  Bad File Path    *********" )
                primeStartButton.title = "Prime Start"
                primeStartButton.state = .off
                return
            }
            primeFinder.makePrimes(largestPrime: lastPrime)

            print( "    *********   makePrimes completed    *********" )
            lastLinePrimeTextField.stringValue = primeFinder.primeFileLastLine!
            primeStartButton.title = "Completed"
            primeStartButton.isEnabled = false
        }
        else    {
            primeStartButton.title = "Stopped"
            primeStartButton.isEnabled = false
            primeFinder.active = value
        }
    }
    
    @IBAction func factorStartAction(sender: NSButton) {
        
        let value = factorStartButton.state == .on
        if value {
            factorStartButton.title = "Running"
            let lastPrime: HLPrimeType = Int64(terminalPrimeTextField.stringValue)!

            errorCode = primeFinder.loadBufFor(prime: lastPrime)
            if errorCode != 0   {   //  serious error
                //  alert user with some kind of hint?
                print( "    *********   Serious Error-  Bad File Path    *********" )
                factorStartButton.title = "Fator Start"
                factorStartButton.state = .off
                return
            }
            
            errorCode = primeFinder.factorPrimes(largestPrime: lastPrime)
            if errorCode == 0   {
                print( "    *********   factorPrimes completed    *********" )
                lastLineFactorTextField.stringValue = primeFinder.factorFileLastLine!
                factorStartButton.title = "Completed"
                factorStartButton.isEnabled = false
            }
            else    {   //  serious error
                factorStartButton.title = "Fator Start"
                factorStartButton.state = .off
            }
        }
        else    {
            factorStartButton.title = "Stopped"
            factorStartButton.isEnabled = false
        }
   }
   
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool    {
        print( "ViewController-  textShouldEndEditing-  control: \(control.stringValue)" )
        
        if control == primeFilePathTextField    {
            var newValue = control.stringValue
            if !newValue.hasPrefix("/")  {
                newValue = homeDir + "/" + newValue
            }
        
            if let lastLine = primeFinder.lastLineFor(path: newValue) {
                lastLinePrimeTextField.stringValue = lastLine
            }
            else    {
                lastLinePrimeTextField.stringValue = "FILE NOT FOUND"
            }
            
            UserDefaults.standard.set(newValue, forKey:HLDefaultPrimeFilePathKey)
        }

        else if control == terminalPrimeTextField    {
            terminalPrimeTextField.stringValue = control.stringValue
            UserDefaults.standard.set(control.stringValue, forKey:HLDefaultTerminalPrimeKey)
        }

        else if control == modCountTextField    {
            modCountTextField.stringValue = control.stringValue
            UserDefaults.standard.set(control.stringValue, forKey:HLDefaultModCountKey)
        }

        else    {   assert( false )     }
        
        UserDefaults.standard.synchronize()
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        lastLinePrimeTextField.stringValue = "?"
        lastLineFactorTextField.stringValue = "?"
        
        if let primeFilePath = UserDefaults.standard.string(forKey: HLDefaultPrimeFilePathKey)  {
            primeFilePathTextField.stringValue = primeFilePath
        }
        else    {
            primeFilePathTextField.stringValue = "Desktop/Primes"
        }
        
        if let terminalPrime = UserDefaults.standard.string(forKey: HLDefaultTerminalPrimeKey)  {
            terminalPrimeTextField.stringValue = terminalPrime
        }
        else    {
            terminalPrimeTextField.stringValue = "169"
        }

        if let modCount = UserDefaults.standard.string(forKey: HLDefaultModCountKey)  {
            modCountTextField.stringValue = modCount
        }
        else    {
            modCountTextField.stringValue = "10"
        }

        primeFinder = HLPrime(primeFilePath: primeFilePathTextField.stringValue)
        
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

