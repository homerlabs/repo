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

    var primeFinder: HLPrime?
    let HLDefaultPrimeFilePathKey       = "PrimeFilePathKey"
    let HLDefaultNicePrimeFilePathKey   = "NicePrimeFilePathKey"
    let HLDefaultTerminalPrimeKey       = "TerminalPrimeKey"
    
    let defaultTerminalPrime = "1000000"
    let primesButtonTitle       = "Find Primes"
    let nicePrimesButtonTitle   = "Find NPrimes"

    var findPrimesInProgress = false
    var findNicePrimesInProgress = false
    var errorCode = 0
    var timer: Timer?
    var updateTimeIsSeconds = 1.0   //  set to 10.0 for terminalCount > 50000000

    var primesURL: URL? = nil
    var nicePrimesURL: URL? = nil
    let HLPrimesBookmarkKey         = "HLPrimesBookmarkKey"
    let HLNicePrimesBookmarkKey     = "HLNicePrimesBookmarkKey"


    @IBAction func setPrimesPathAction(sender: NSButton) {
        if let path = getSaveFilePath(title: "Set Primes file path", fileName: "Primes", bookmarkKey: HLPrimesBookmarkKey)  {
            primeFilePathTextField.stringValue = path
            UserDefaults.standard.set(path, forKey:HLDefaultPrimeFilePathKey)
            primesURL = path.getBookmarkFor(key: HLPrimesBookmarkKey)
        }
    }

    @IBAction func setNicePrimesPathAction(sender: NSButton) {
        if let path = getSaveFilePath(title: "Set NicePrimes file path", fileName: "NicePrimes", bookmarkKey: HLNicePrimesBookmarkKey)  {
            nicePrimeFilePathTextField.stringValue = path
            UserDefaults.standard.set(path, forKey:HLDefaultNicePrimeFilePathKey)
            primesURL = path.getBookmarkFor(key: HLNicePrimesBookmarkKey)
        }
    }

   func getOpenFilePath(title: String, bookmarkKey: String) -> String?     {
    
        var path: String?
        let openPanel = NSOpenPanel();
        openPanel.canCreateDirectories = true;
        openPanel.allowedFileTypes = ["txt"];
        openPanel.showsTagField = false;
        openPanel.prompt = "Open";
        openPanel.message = title;

        let i = openPanel.runModal();
        if(i == NSApplication.ModalResponse.OK){
            path = openPanel.url!.path
            openPanel.url!.setBookmarkFor(key: bookmarkKey)
        }
    
    print( "getOpenFilePath: \(title),  Bookmark: \(bookmarkKey)  return: \(String(describing: path))" )
        return path
    }

   func getSaveFilePath(title: String, fileName: String, bookmarkKey: String) -> String?     {
    
        var path: String?
        let savePanel = NSSavePanel();
        savePanel.canCreateDirectories = true;
        savePanel.title = "PrimeFinder Save Panel";
        savePanel.nameFieldStringValue = fileName;
        savePanel.showsTagField = false;
        savePanel.prompt = "Create";
        savePanel.message = title;
        savePanel.nameFieldLabel = "Save As:";
        savePanel.allowedFileTypes = ["txt"];

        let i = savePanel.runModal();
        if(i == NSApplication.ModalResponse.OK){
            path = savePanel.url!.path
            savePanel.url!.setBookmarkFor(key: bookmarkKey)
        }
    
    print( "getSaveFilePath: \(title),  Bookmark: \(bookmarkKey)  return: \(String(describing: path))" )
        return path
    }


    @IBAction func primesStartAction(sender: NSButton) {
        
        if !findPrimesInProgress {
            primeButton.title = "Running"
            nicePrimesButton.isEnabled = false

            if primesURL == nil   {
                print( "primesURL is nil" )
                
                if let path = getSaveFilePath(title: "Set Primes file path", fileName: "Primes", bookmarkKey: HLPrimesBookmarkKey)  {
                    primeFilePathTextField.stringValue = path
                    UserDefaults.standard.set(path, forKey:HLDefaultPrimeFilePathKey)
                    primesURL = path.getBookmarkFor(key: HLPrimesBookmarkKey)
                }
            }
            
            primeFinder = HLPrime(primeFilePath: primeFilePathTextField.stringValue, delegate: self)
            if primeFinder != nil {
                primeFinder!.findPrimes(largestPrime: Int64(terminalPrimeTextField.stringValue)!)
                
                if terminalPrimeTextField.intValue >= 50000000   {
                    updateTimeIsSeconds *= 10
                }
                
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: updateTimeIsSeconds, repeats: true, block: {_ in
                    self.progressTextField.stringValue = String(self.primeFinder!.lastP)
                    })
            }
        }
        else    {
            primeButton.title = primesButtonTitle
            primeFinder?.active = false
        }
        
        findPrimesInProgress = !findPrimesInProgress
    }
    

    @IBAction func nicePrimesAction(sender: NSButton) {
        if !findNicePrimesInProgress {
            nicePrimesButton.title = "Running"
            findNicePrimesInProgress = true
            primeButton.isEnabled = false

            if primesURL == nil   {
                print( "primesURL is nil" )
                
                if let path = getOpenFilePath(title: "Open Primes file", bookmarkKey: HLPrimesBookmarkKey)  {
                    primeFilePathTextField.stringValue = path
                    UserDefaults.standard.set(path, forKey:HLDefaultPrimeFilePathKey)
                    primesURL = path.getBookmarkFor(key: HLPrimesBookmarkKey)
                }
            }
            
            if nicePrimesURL == nil   {
                print( "nicePrimesURL is nil" )
                
                if let path = getSaveFilePath(title: "Set NicePrimes file path", fileName: "NicePrimes", bookmarkKey: HLNicePrimesBookmarkKey)     {
                    nicePrimeFilePathTextField.stringValue = path
                    UserDefaults.standard.set(path, forKey:HLDefaultNicePrimeFilePathKey)
                    nicePrimesURL = path.getBookmarkFor(key: HLNicePrimesBookmarkKey)
                }
            }
            
            let path = primeFilePathTextField.stringValue
            primeFinder = HLPrime(primeFilePath: path, delegate: self)
            if primeFinder != nil {
                let path2 = nicePrimeFilePathTextField.stringValue
      //          primeFinder?.makeNicePrimesFile(nicePrimePath: path2, largestPrime: Int64(terminalPrimeTextField.stringValue)!)
                primeFinder?.scanPrimesFile(nicePrimePath: path2)
                
                if terminalPrimeTextField.intValue >= 50000000   {
                    updateTimeIsSeconds *= 10
                }
                
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: updateTimeIsSeconds, repeats: true, block: {_ in
                    self.progressTextField.stringValue = String(self.primeFinder!.lastP)
                    })
            }
       }
        else    {
            nicePrimesButton.title = nicePrimesButtonTitle
            primeFinder?.active = false
        }
    }
    
    //*************   HLPrimeProtocol     *********************************************************
    func findPrimesCompleted(lastLine: String)  {
        let elaspsedTime = primeFinder!.actionTimeInSeconds.formatTime()
        print( "    *********   findPrimes completed in \(elaspsedTime)    *********\n" )
        findPrimesInProgress = false
        progressTextField.stringValue = lastLine
        primeButton.title = primesButtonTitle
        nicePrimesButton.isEnabled = true
        timer?.invalidate()
    }
    
    func findNicePrimesCompleted(lastLine: String)  {
        let elaspsedTime = primeFinder!.actionTimeInSeconds.formatTime()
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
        print( "ViewController-  viewDidDisappear" )
        primeFinder?.active = false //  exit loop and close files
        primesURL?.stopAccessingSecurityScopedResource()
        nicePrimesURL?.stopAccessingSecurityScopedResource()
        exit(0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressTextField.stringValue = "?"

        if let primeFilePath = UserDefaults.standard.string(forKey: HLDefaultPrimeFilePathKey)  {
            primesURL = primeFilePath.getBookmarkFor(key: HLPrimesBookmarkKey)
            if primesURL != nil {
                primeFilePathTextField.stringValue = primeFilePath
            }
        }

        if let nicePrimeFilePath = UserDefaults.standard.string(forKey: HLDefaultNicePrimeFilePathKey)  {
            nicePrimesURL = nicePrimeFilePath.getBookmarkFor(key: HLNicePrimesBookmarkKey)
            if nicePrimesURL != nil {
                nicePrimeFilePathTextField.stringValue = nicePrimeFilePath
            }
        }

        if let terminalPrime = UserDefaults.standard.string(forKey: HLDefaultTerminalPrimeKey)  {
            terminalPrimeTextField.stringValue = terminalPrime
        }
        else    {
            terminalPrimeTextField.stringValue = defaultTerminalPrime
        }
        
        progressTextField.stringValue = "Idle"
    }
}

