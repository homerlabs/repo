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
    var findNicePrimesInProgress = false
    var factorPrimesInProgress = false
    var errorCode = 0

    @IBAction func checkProgressAction(sender: NSButton) {
            progressTextField.stringValue = String(primeFinder.lastP)
    }
    
    @IBAction func filterAction(sender: NSButton) {
        if filterStartButton.state == .on {
            filterStartButton.title = "Running"
            primeFinder.makeNicePrimesFile2(largestPrime: Int64(terminalPrimeTextField.stringValue)!)
            findNicePrimesInProgress = true
        }
        else    {
            filterStartButton.title = "Stopped"
            filterStartButton.isEnabled = false
            primeFinder.active = false
        }
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
    func hlPrimeInitCompleted()  {
        let elaspsedTime = primeFinder.actionTimeInSeconds.formatTime()
        print( "    *********   HLPrime init completed in \(elaspsedTime)    *********\n" )
        findPrimesInProgress = false
        
        if primeFinder.primeFileLastLine != nil {
            lastLinePrimeTextField.stringValue = primeFinder.primeFileLastLine!
            factorStartButton.isEnabled = true
            filterStartButton.isEnabled = true
        }
        
        if primeFinder.factorFileLastLine != nil {
            lastLineFactorTextField.stringValue = primeFinder.factorFileLastLine!
        }
        
        primeStartButton.isEnabled = true
        primeStartButton.title = "Prime Start"
        factorStartButton.title = "Factor Start"
        filterStartButton.title = "Filter Start"
    }
    
    func findPrimesCompleted()  {
        let elaspsedTime = primeFinder.actionTimeInSeconds.formatTime()
        print( "    *********   findPrimes completed in \(elaspsedTime)    *********\n" )
        findPrimesInProgress = false
        lastLinePrimeTextField.stringValue = primeFinder.primeFileLastLine!
        primeStartButton.title = "Completed"
        primeStartButton.isEnabled = false
        
        factorStartButton.isEnabled = true
        filterStartButton.isEnabled = true
    }
    
    func findNicePrimesCompleted()  {
        let elaspsedTime = primeFinder.actionTimeInSeconds.formatTime()
        print( "    *********   findNicePrimes completed in \(elaspsedTime)    *********\n" )
        findNicePrimesInProgress = false
        lastLinePrimeTextField.stringValue = primeFinder.primeFileLastLine!
        filterStartButton.title = "Completed"
        filterStartButton.isEnabled = false
    }
    
    func factorPrimesCompleted()    {
        let elaspsedTime = primeFinder.actionTimeInSeconds.formatTime
        print( "    *********   makePrimes completed  in \(elaspsedTime)    *********\n" )
        factorPrimesInProgress = false
        lastLineFactorTextField.stringValue = primeFinder.factorFileLastLine!
        factorStartButton.title = "Completed"
        factorStartButton.isEnabled = false
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lastLinePrimeTextField.stringValue = "?"
        lastLineFactorTextField.stringValue = "?"
        progressTextField.stringValue = "?"

        primeStartButton.isEnabled = false
        factorStartButton.isEnabled = false
        filterStartButton.isEnabled = false

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

