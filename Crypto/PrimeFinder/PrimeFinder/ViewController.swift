//
//  ViewController.swift
//  HLPrimes
//
//  Created by Matthew Homer on 5/28/17.
//  Copyright © 2017 HomerLabs. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSControlTextEditingDelegate, HLPrimesProtocol {

    @IBOutlet var primeFilePathTextField: NSTextField!
    @IBOutlet var lastLinePrimeTextField: NSTextField!
    @IBOutlet var lastLineFactorTextField: NSTextField!
    @IBOutlet var terminalPrimeTextField: NSTextField!
    @IBOutlet var modCountTextField: NSTextField!
    @IBOutlet var progressTextField: NSTextField!

    @IBOutlet var primeStartButton: NSButton!
    @IBOutlet var factorStartButton: NSButton!
    @IBOutlet var filterStartButton: NSButton!

    var primeFinder: HLPrime!
    let HLDefaultPrimeFilePathKey = "PrimeFilePathKey"
    let HLDefaultTerminalPrimeKey = "TerminalPrimeKey"
    let HLDefaultModCountKey = "ModCountKey"
    
    let defaultTerminalPrime = "1000000"
    let defaultModSize = "100000"
    
    var findPrimesInProgress = false
    var factorPrimesInProgress = false
    var errorCode = 0

    @IBAction func checkProgressAction(sender: NSButton) {
     //       print( "    *********   checkProgressAction    lastP: \(primeFinder.lastP)" )
            progressTextField.stringValue = String(primeFinder.lastP)
    }
    
    @IBAction func filterAction(sender: NSButton) {
     //       print( "    *********   filterAction    lastP: \(primeFinder.lastP)" )
            primeFinder.makeNicePrimesFile()
    }
    
    @IBAction func primesStartAction(sender: NSButton) {
        
        if primeStartButton.state == .on {
            primeStartButton.title = "Running"
            primeFinder.findPrimes(largestPrime: Int64(terminalPrimeTextField.stringValue)!)
            findPrimesInProgress = true
        }
        else    {
            primeStartButton.title = "Stopped"
            primeStartButton.isEnabled = false
            primeFinder.active = false
        }
    }
    
    @IBAction func factorStartAction(sender: NSButton) {
        
        if factorStartButton.state == .on {
            factorStartButton.title = "Running"
            primeFinder.factorPrimes(largestPrime: Int64(terminalPrimeTextField.stringValue)!)
            factorPrimesInProgress = true
        }
        else    {
            factorStartButton.title = "Stopped"
            factorStartButton.isEnabled = false
            primeFinder.active = false
        }
   }
   
    //*************   HLPrimeProtocol     *********************************************************
    func findPrimesCompleted()  {
        let elaspsedTime = formatTime(timeInSeconds: primeFinder.actionTimeInSeconds)
        print( "    *********   findPrimes completed in \(elaspsedTime)    *********\n" )
        findPrimesInProgress = false
        lastLinePrimeTextField.stringValue = primeFinder.primeFileLastLine!
        primeStartButton.title = "Completed"
        primeStartButton.isEnabled = false
    }
    
    func factorPrimesCompleted()    {
        let elaspsedTime = formatTime(timeInSeconds: primeFinder.actionTimeInSeconds)
        print( "    *********   makePrimes completed  in \(elaspsedTime)    *********\n" )
        factorPrimesInProgress = false
        lastLineFactorTextField.stringValue = primeFinder.factorFileLastLine!
        factorStartButton.title = "Completed"
        factorStartButton.isEnabled = false

 //       primeFinder.makeNicePrimesFile()
    }
    //*************   HLPrimeProtocol     *********************************************************


    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool    {
        print( "ViewController-  textShouldEndEditing-  control: \(control.stringValue)" )
        
        if control == primeFilePathTextField    {
            var newValue = control.stringValue
            if !newValue.hasPrefix("/")  {
                newValue = "/Users/" + NSUserName() + "/" + newValue
            }
            
            primeFinder.setupFilePaths(basePath: newValue)
        
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
            primeFinder.fileManager.setModSize(control.intValue)
            modCountTextField.stringValue = control.stringValue
            UserDefaults.standard.set(control.stringValue, forKey:HLDefaultModCountKey)
        }

        else    {   assert( false )     }
        
        UserDefaults.standard.synchronize()
        return true
    }
    
    func formatTime(timeInSeconds: Int) -> String   {
        let hours = timeInSeconds / 3600
        let mintues = timeInSeconds / 60 - hours * 60
        let seconds = timeInSeconds - hours * 3600 - mintues * 60
        return String(format: "%02d:%02d:%02d", hours, mintues, seconds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        lastLinePrimeTextField.stringValue = "?"
        lastLineFactorTextField.stringValue = "?"
        progressTextField.stringValue = "?"

        if let primeFilePath = UserDefaults.standard.string(forKey: HLDefaultPrimeFilePathKey)  {
            primeFilePathTextField.stringValue = primeFilePath
        }
        else    {
            primeFilePathTextField.stringValue = "/Users/" + NSUserName() + "/Desktop/Primes"
        }
        
        if let terminalPrime = UserDefaults.standard.string(forKey: HLDefaultTerminalPrimeKey)  {
            terminalPrimeTextField.stringValue = terminalPrime
        }
        else    {
            terminalPrimeTextField.stringValue = defaultTerminalPrime
        }

        if let modCount = UserDefaults.standard.string(forKey: HLDefaultModCountKey)  {
            modCountTextField.stringValue = modCount
        }
        else    {
            modCountTextField.stringValue = defaultModSize
        }

        primeFinder = HLPrime(primeFilePath: primeFilePathTextField.stringValue, modCount: modCountTextField.intValue, delegate: self)
        
        if let primeLastLine = primeFinder.primeFileLastLine    {
            lastLinePrimeTextField.stringValue = primeLastLine
        }
        
        if let factoredLastLine = primeFinder.factorFileLastLine    {
            lastLineFactorTextField.stringValue = factoredLastLine
        }
    }
}

