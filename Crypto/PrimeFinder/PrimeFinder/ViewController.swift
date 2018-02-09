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
    @IBOutlet var nicePrimeFilePathTextField: NSTextField!
//    @IBOutlet var lastLinePrimeTextField: NSTextField!
    @IBOutlet var terminalPrimeTextField: NSTextField!
    @IBOutlet var modCountTextField: NSTextField!
    @IBOutlet var progressTextField: NSTextField!

    @IBOutlet var primeButton: NSButton!
    @IBOutlet var nicePrimesButton: NSButton!

    var primeFinder: HLPrime?
    let HLDefaultPrimeFilePathKey       = "PrimeFilePathKey"
    let HLDefaultNicePrimeFilePathKey   = "NicePrimeFilePathKey"
    let HLDefaultTerminalPrimeKey       = "TerminalPrimeKey"
    let HLDefaultModCountKey            = "ModCountKey"
    
    let defaultTerminalPrime = "1000000"
    let defaultModSize = "100000"
    
    var findPrimesInProgress = false
    var findNicePrimesInProgress = false
    var factorPrimesInProgress = false
    var errorCode = 0

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


    @IBAction func checkProgressAction(sender: NSButton) {
        progressTextField.stringValue = String(describing: primeFinder?.lastP)
    }
    
    @IBAction func primesStartAction(sender: NSButton) {
        
        if primeButton.state == .on {
            primeButton.title = "Running"
            findPrimesInProgress = true
            
            if primesURL == nil   {
                print( "primesURL is nil" )
                
                if let path = getSaveFilePath(title: "Set Primes file path", fileName: "Primes", bookmarkKey: HLPrimesBookmarkKey)  {
                    primeFilePathTextField.stringValue = path
                    UserDefaults.standard.set(path, forKey:HLDefaultPrimeFilePathKey)
                    primesURL = path.getBookmarkFor(key: HLPrimesBookmarkKey)
                }
            }
            
            primeFinder = HLPrime(primeFilePath: primeFilePathTextField.stringValue, modCount: modCountTextField.intValue, delegate: self)
            primeFinder?.findPrimes(largestPrime: Int64(terminalPrimeTextField.stringValue)!)
        }
        else    {
            primeButton.title = "Stopped"
     //       primeButton.isEnabled = false
      //      primeFinder?.active = false
        }
    }
    

    @IBAction func nicePrimesAction(sender: NSButton) {
        if nicePrimesButton.state == .on {
            nicePrimesButton.title = "Running"
            findNicePrimesInProgress = true
           
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
            primeFinder = HLPrime(primeFilePath: path, modCount: modCountTextField.intValue, delegate: self)
            primeFinder?.makeNicePrimesFile2(nicePrimePath: nicePrimeFilePathTextField.stringValue, largestPrime: Int64(terminalPrimeTextField.stringValue)!)
       }
        else    {
            nicePrimesButton.title = "Stopped"
            nicePrimesButton.isEnabled = false
            primeFinder?.active = false
        }
    }
    
    //*************   HLPrimeProtocol     *********************************************************
/*    func hlPrimeInitCompleted()  {
        let elaspsedTime = primeFinder.actionTimeInSeconds.formatTime()
        print( "    *********   HLPrime init completed in \(elaspsedTime)    *********\n" )
        findPrimesInProgress = false
        
        if primeFinder.primeFileLastLine != nil {
            lastLinePrimeTextField.stringValue = primeFinder.primeFileLastLine!
            nicePrimesButton.isEnabled = true
            nicePrimesButton.isEnabled = true
        }
        
        primeButton.isEnabled = true
        primeButton.title = "Prime Start"
    }   */
    
    func findPrimesCompleted()  {
        let elaspsedTime = primeFinder!.actionTimeInSeconds.formatTime()
        print( "    *********   findPrimes completed in \(elaspsedTime)    *********\n" )
        findPrimesInProgress = false
 //       lastLinePrimeTextField.stringValue = primeFinder.primeFileLastLine!
        primeButton.title = "Completed"
        primeButton.isEnabled = false
    }
    
    func findNicePrimesCompleted()  {
        let elaspsedTime = primeFinder!.actionTimeInSeconds.formatTime()
        print( "    *********   findNicePrimes completed in \(elaspsedTime)    *********\n" )
        findNicePrimesInProgress = false
//        lastLinePrimeTextField.stringValue = primeFinder.primeFileLastLine!
        nicePrimesButton.title = "Completed"
        nicePrimesButton.isEnabled = false
    }
    
/*    func factorPrimesCompleted()    {
        let elaspsedTime = primeFinder.actionTimeInSeconds.formatTime()
        print( "    *********   makePrimes completed  in \(elaspsedTime)    *********\n" )
        factorPrimesInProgress = false
        lastLineFactorTextField.stringValue = primeFinder.factorFileLastLine!
        factorStartButton.title = "Completed"
        factorStartButton.isEnabled = false
    }   */
    //*************   HLPrimeProtocol     *********************************************************


    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool    {
        print( "ViewController-  textShouldEndEditing-  control: \(control.stringValue)" )
        
/*        if control == primeFilePathTextField    {
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
        }   */

        if control == terminalPrimeTextField    {
            terminalPrimeTextField.stringValue = control.stringValue
            UserDefaults.standard.set(control.stringValue, forKey:HLDefaultTerminalPrimeKey)
        }

        else if control == modCountTextField    {
            primeFinder?.fileManager.setModSize(control.intValue)
            modCountTextField.stringValue = control.stringValue
            UserDefaults.standard.set(control.stringValue, forKey:HLDefaultModCountKey)
        }

        else    {   assert( false )     }
        
        UserDefaults.standard.synchronize()
        return true
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        print( "ViewController-  viewDidDisappear" )
        primesURL?.stopAccessingSecurityScopedResource()
        nicePrimesURL?.stopAccessingSecurityScopedResource()
        exit(0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 //       lastLinePrimeTextField.stringValue = "?"
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

        if let modCount = UserDefaults.standard.string(forKey: HLDefaultModCountKey)  {
            modCountTextField.stringValue = modCount
        }
        else    {
            modCountTextField.stringValue = defaultModSize
        }

 //       if
 //       primeFinder = HLPrime(primeFilePath: primeFilePathTextField.stringValue, modCount: modCountTextField.intValue, delegate: self)
        
 //       if let primeLastLine = primeFinder.primeFileLastLine    {
 //           lastLinePrimeTextField.stringValue = primeLastLine
  //      }
    }
}

