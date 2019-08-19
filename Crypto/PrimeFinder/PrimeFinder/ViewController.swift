//
//  ViewController.swift
//  HLPrimes
//
//  Created by Matthew Homer on 5/28/17.
//  Copyright © 2017 HomerLabs. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSControlTextEditingDelegate, HLPrimesProtocol {

    @IBOutlet weak var primeFilePathTextField: NSTextField!
    @IBOutlet weak var nicePrimeFilePathTextField: NSTextField!
    @IBOutlet weak var terminalPrimeTextField: NSTextField!
    @IBOutlet weak var progressTextField: NSTextField!

    @IBOutlet weak var primeButton: NSButton!
    @IBOutlet weak var nicePrimesButton: NSButton!

    let HLPrimesBookmarkKey         = "HLPrimesBookmarkKey"
    let HLNicePrimesBookmarkKey     = "HLNicePrimesBookmarkKey"
    let HLDefaultTerminalPrimeKey   = "TerminalPrimeKey"
    let HLSavePanelTitle            = "PrimeFinder Save Panel"
    var primesURL: URL?
    var nicePrimesURL: URL?
    
    var primeFinder: HLPrime?   //  the Model in MVC
    
    let defaultTerminalPrime = "1000000"
    let primesButtonTitle       = "Find Primes"
    let nicePrimesButtonTitle   = "Find NPrimes"

    var findPrimesInProgress = false
    var findNicePrimesInProgress = false
    var errorCode = 0
    var timer: Timer?
    var updateTimeIsSeconds = 1.0   //  set to 10.0 for terminalCount > 50000000

    @IBAction func quiitAction(_ sender: Any) {
        print( "quiitAction" )
        
        primeFinder?.okToRun = false //  force exit loop and close files
        primesURL?.stopAccessingSecurityScopedResource()
        nicePrimesURL?.stopAccessingSecurityScopedResource()
    }

    @IBAction func setPrimesPathAction(sender: NSButton) {
        primesURL = getSaveFilePath(title: HLSavePanelTitle, message: "Set Primes file path", fileName: "Primes")
        if primesURL != nil  {
            primeFilePathTextField.stringValue = primesURL!.path
            primeButton.isEnabled = true
        }
    }

    @IBAction func setNicePrimesPathAction(sender: NSButton) {
        nicePrimesURL = getSaveFilePath(title: HLSavePanelTitle, message: "Set NicePrimes file path", fileName: "NicePrimes")
        if nicePrimesURL != nil  {
            nicePrimeFilePathTextField.stringValue = nicePrimesURL!.path
            nicePrimesButton.isEnabled = true
        }
    }

    @IBAction func findPrimesStartAction(sender: NSButton) {
        
        if !findPrimesInProgress {
            primeButton.title = "Running"
            nicePrimesButton.isEnabled = false

        if primesURL == nil   {
            primesURL = getSaveFilePath(title: HLSavePanelTitle, message: "Set Primes file path", fileName: "Primes")

            guard primesURL != nil else { return }
            primeFilePathTextField.stringValue = primesURL!.path
        }

        if primesURL != nil   {
            primeFinder = HLPrime(primesFileURL: primesURL!, delegate: self)
            setBookmarkFor(key: HLPrimesBookmarkKey, url: primesURL!)
        }

            primeFinder?.findPrimes(maxPrime: HLPrimeType(terminalPrimeTextField.stringValue)!)
            
            if terminalPrimeTextField.intValue >= 50000000   {
                updateTimeIsSeconds = 10
            }
            else {
                updateTimeIsSeconds = 1
            }
        
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: updateTimeIsSeconds, repeats: true, block: {_ in
                self.progressTextField.stringValue = String(self.primeFinder!.lastP)
                })
        }
        else {
            primeButton.title = primesButtonTitle
            primeFinder?.okToRun = false
        }
        
        findPrimesInProgress = !findPrimesInProgress
        }

    @IBAction func findNicePrimesAction(sender: NSButton) {
        if !findNicePrimesInProgress {
            nicePrimesButton.title = "Running"
            findNicePrimesInProgress = true
            primeButton.isEnabled = false

            if primesURL == nil   {
                print( "primesURL is nil" )
                
                primesURL = getOpenFilePath(title: "Open Primes file", bookmarkKey: HLPrimesBookmarkKey)
                guard primesURL != nil else { return }
                
                primeFilePathTextField.stringValue = primesURL!.path
                primeFinder = HLPrime(primesFileURL: primesURL!, delegate: self)
            }
            
            if nicePrimesURL == nil   {
                print( "nicePrimesURL is nil" )
                
                nicePrimesURL = getSaveFilePath(title: "Set NicePrimes file path", message: "Set NicePrimes file path", fileName: "NicePrimes")
                guard nicePrimesURL != nil else { return }
                
                nicePrimeFilePathTextField.stringValue = nicePrimesURL!.path
                setBookmarkFor(key: HLNicePrimesBookmarkKey, url: nicePrimesURL!)
            }
            
            //  at this point we know we have valid primesURL and nicePrimesURL
            primeFinder = HLPrime(primesFileURL: primesURL!, delegate: self)
            primeFinder!.makeNicePrimesFile(nicePrimeURL: nicePrimesURL!)
            
            if terminalPrimeTextField.intValue >= 50000000   {
                updateTimeIsSeconds *= 10
            }
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: updateTimeIsSeconds, repeats: true, block: {_ in
                self.progressTextField.stringValue = String(self.primeFinder!.lastP)
                })
       }
        else    {
            nicePrimesButton.title = nicePrimesButtonTitle
            primeFinder?.okToRun = false
        }
    }
    
    //*************   HLPrimeProtocol     *********************************************************
    func findPrimesCompleted(lastLine: String)  {
        let elaspsedTime = primeFinder!.timeInSeconds.formatTime()
        print( "    *********   findPrimes completed in \(elaspsedTime)    *********\n" )
        findPrimesInProgress = false
        progressTextField.stringValue = lastLine
        primeButton.title = primesButtonTitle
        nicePrimesButton.isEnabled = true
        timer?.invalidate()
    }
    
    func findNicePrimesCompleted(lastLine: String)  {
        let elaspsedTime = primeFinder!.timeInSeconds.formatTime()
        print( "    *********   findNicePrimes completed in \(elaspsedTime)    *********\n" )
        findNicePrimesInProgress = false
        progressTextField.stringValue = lastLine
        nicePrimesButton.title = nicePrimesButtonTitle
        primeButton.isEnabled = true
        timer?.invalidate()
    }
    //*************   HLPrimeProtocol     *********************************************************


    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool    {
        print( "ViewController-  textShouldEndEditing-  control: \(control.stringValue)" )
        
        if control == terminalPrimeTextField    {
            terminalPrimeTextField.stringValue = control.stringValue
            UserDefaults.standard.set(control.stringValue, forKey:HLDefaultTerminalPrimeKey)
        }

        else    {   assert( false )     }
        
        UserDefaults.standard.synchronize()
        return true
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
  //      print( "ViewController-  viewDidDisappear" )
        
        primeFinder?.okToRun = false //  force exit loop and close files
        primesURL?.stopAccessingSecurityScopedResource()
        nicePrimesURL?.stopAccessingSecurityScopedResource()
        
        NSApplication.shared.terminate(self) //  if main window closes then quit app
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressTextField.stringValue = "Idle"
        primeButton.isEnabled = false
        nicePrimesButton.isEnabled = false

        primesURL = getBookmarkFor(key: HLPrimesBookmarkKey)
        if primesURL != nil {
            primeFilePathTextField.stringValue = primesURL!.path
            primeButton.isEnabled = true
        }

        nicePrimesURL = getBookmarkFor(key: HLNicePrimesBookmarkKey)
        if nicePrimesURL != nil {
            nicePrimeFilePathTextField.stringValue = nicePrimesURL!.path
            nicePrimesButton.isEnabled = true
        }

        if let terminalPrime = UserDefaults.standard.string(forKey: HLDefaultTerminalPrimeKey)  {
            terminalPrimeTextField.stringValue = terminalPrime
        }
        else    {
            terminalPrimeTextField.stringValue = defaultTerminalPrime
        }
    }
}

