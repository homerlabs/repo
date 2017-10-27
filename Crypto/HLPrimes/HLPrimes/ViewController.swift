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
    @IBOutlet var factorFilePathTextField: NSTextField!
    @IBOutlet var lastLinePrimeTextField: NSTextField!
    @IBOutlet var lastLineFactorTextField: NSTextField!
    @IBOutlet var terminalPrimeTextField: NSTextField!
    @IBOutlet var modCountTextField: NSTextField!
    @IBOutlet var progressTextField: NSTextField!

    @IBOutlet var primeStartButton: NSButton!
    @IBOutlet var factorStartButton: NSButton!

    var primeFinder: HLPrime!
    let HLDefaultPrimeFilePathKey = "PrimeFilePathKey"
    let HLDefaultTerminalPrimeKey = "TerminalPrimeKey"
    let HLDefaultModCountKey = "ModCountKey"
    
    let defaultTerminalPrime = "72361"  //  269 squared
    let defaultModSize = "1000"
    
    var primeLastLine: String?
    var factoredLastLine: String?
    
    var findPrimesInProgress = false
    var factorPrimesInProgress = false

    let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
    var errorCode = 0

    @IBAction func checkProgressAction(sender: NSButton) {
     //       print( "    *********   checkProgressAction    lastP: \(primeFinder.lastP)" )
            progressTextField.stringValue = String(primeFinder.lastP)
    }
    
    @IBAction func primeStartAction(sender: NSButton) {
        
        if primeStartButton.state == .on {
            print( "\n    *********   Loading buffer to begin finding primes                *********" )
            primeStartButton.title = "Running"
            
            let _ = checkLargestPrimeSizeIsOk(largestPrimeToFind: terminalPrimeTextField.stringValue, primeFileLastLine: primeLastLine)
            let lastPrime: HLPrimeType = Int64(terminalPrimeTextField.stringValue)!
            let largestTestPrime = Int64(sqrt(Double(lastPrime)))
            errorCode = primeFinder.loadBufFor(largestPrime: largestTestPrime)
            if errorCode != 0   {   //  serious error
                //  alert user with some kind of hint?
                print( "    *********   Serious Error-  Bad File Path    *********" )
                primeStartButton.title = "Prime Start"
                primeStartButton.state = .off
                return
            }
            
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
            print( "\n    *********   Loading buffer to begin factoring primes                   *********" )
            factorStartButton.title = "Running"
            let lastPrime: HLPrimeType = Int64(terminalPrimeTextField.stringValue)!

            let largestTestPrime = lastPrime / 2
            errorCode = primeFinder.loadBufFor(largestPrime: largestTestPrime)
            if errorCode != 0   {   //  serious error
                //  alert user with some kind of hint?
                print( "    *********   Serious Error-  Bad File Path    *********" )
                factorStartButton.title = "Fator Start"
                factorStartButton.state = .off
                return
            }
            
            factorPrimesInProgress = true
        }
        else    {
            factorStartButton.title = "Stopped"
            factorStartButton.isEnabled = false
            primeFinder.active = false
        }
   }
   
   
    //*************   HLPrimeProtocol     *********************************************************
    func makePrimesCompleted()  {
        let elaspsedTime = formatTime(timeInSeconds: primeFinder.actionTimeInSeconds)
        print( "    *********   makePrimes completed in \(elaspsedTime)    *********\n" )
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

        primeFinder.makeNicePrimesFile()
    }
    
    func loadBufCompleted()    {
        let elaspsedTime = formatTime(timeInSeconds: primeFinder.actionTimeInSeconds)
        print( "    *********   loadBuf completed with last prime = \(primeFinder.largestBufPrime)  in \(elaspsedTime)   *********" )
        
        let terminalPrime: HLPrimeType = Int64(terminalPrimeTextField.stringValue)!
        
        if findPrimesInProgress   {
            let largestPossiblePrimeToFactor = primeFinder.largestBufPrime * primeFinder.largestBufPrime
            if largestPossiblePrimeToFactor < terminalPrime  {
                print( "terminalPrime: \(terminalPrime)    largestPossiblePrimeToFactor: \(largestPossiblePrimeToFactor)" )
                terminalPrimeTextField.stringValue = String(largestPossiblePrimeToFactor)
            }
            
            primeFinder.makePrimes(largestPrime: Int64(terminalPrimeTextField.stringValue)!)
        }
        
        if factorPrimesInProgress   {
            let largestPossiblePrimeToFactor = primeFinder.largestBufPrime * 2
            if largestPossiblePrimeToFactor < terminalPrime  {
                print( "terminalPrime: \(terminalPrime)    largestPossiblePrimeToFactor: \(largestPossiblePrimeToFactor)" )
                terminalPrimeTextField.stringValue = String(largestPossiblePrimeToFactor)
            }
            
            primeFinder.factorPrimes(largestPrime: Int64(terminalPrimeTextField.stringValue)!)
        }
    }
    //*************   HLPrimeProtocol     *********************************************************


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
            primeFinder.fileManager.setModSize(control.intValue)
            modCountTextField.stringValue = control.stringValue
            UserDefaults.standard.set(control.stringValue, forKey:HLDefaultModCountKey)
        }

        else    {   assert( false )     }
        
        UserDefaults.standard.synchronize()
        return true
    }
    
    func checkLargestPrimeSizeIsOk(largestPrimeToFind: String, primeFileLastLine: String?) -> Bool   {
        var isOk = true
        if let fileLastLine = primeFileLastLine     {
            let (_, lastP) = primeFinder.parseLine(line: fileLastLine)
            let terminalPrime = terminalPrimeTextField.stringValue
            let largestPrimeNeeded = Int64(sqrt(Double(terminalPrime)!))
            if largestPrimeNeeded > lastP   {
                isOk = false
                let largestPossibleTestPrime = lastP * lastP
                terminalPrimeTextField.stringValue = String(largestPossibleTestPrime)
                UserDefaults.standard.set(largestPossibleTestPrime, forKey:HLDefaultTerminalPrimeKey)
                UserDefaults.standard.synchronize()
            }
        }
        
        else    {   isOk = false   }
        
        return isOk
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
            primeFilePathTextField.stringValue = "Desktop/Primes"
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
        
        primeLastLine = primeFinder.primeFileLastLine
        if primeLastLine != nil  {
            lastLinePrimeTextField.stringValue = primeLastLine!
            let _ = checkLargestPrimeSizeIsOk(largestPrimeToFind: terminalPrimeTextField.stringValue, primeFileLastLine: primeLastLine!)

        }
        else    {
            terminalPrimeTextField.stringValue = defaultTerminalPrime
            UserDefaults.standard.set(defaultTerminalPrime, forKey:HLDefaultTerminalPrimeKey)

            primeFinder.fileManager.setModSize(Int32(defaultModSize)!)
            modCountTextField.stringValue = defaultModSize
            UserDefaults.standard.set(defaultModSize, forKey:HLDefaultModCountKey)
        }
        
        factoredLastLine = primeFinder.factorFileLastLine
        if factoredLastLine != nil  {
            lastLineFactorTextField.stringValue = factoredLastLine!
        }
    }
}

