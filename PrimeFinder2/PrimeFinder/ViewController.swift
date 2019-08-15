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
 //   let HLDefaultPrimeFilePathKey       = "PrimeFilePathKey"
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
        primesURL = getSaveFilePath(title: "Set Primes file path", fileName: "Primes", bookmarkKey: HLPrimesBookmarkKey)
        if primesURL != nil  {
            primeFilePathTextField.stringValue = primesURL!.path
  //          UserDefaults.standard.set(url, forKey:HLDefaultPrimeFilePathKey)
            primeButton.isEnabled = true
        }
    }

    @IBAction func setNicePrimesPathAction(sender: NSButton) {
        if let url = getSaveFilePath(title: "Set NicePrimes file path", fileName: "NicePrimes", bookmarkKey: HLNicePrimesBookmarkKey)  {
            nicePrimeFilePathTextField.stringValue = url.path
            UserDefaults.standard.set(url, forKey:HLDefaultNicePrimeFilePathKey)
    //        nicePrimesURL = path.getBookmarkFor(key: HLNicePrimesBookmarkKey)
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
  //         openPanel.url!.setBookmarkFor(key: bookmarkKey)
        }
    
    print( "getOpenFilePath: \(title),  Bookmark: \(bookmarkKey)  return: \(String(describing: path))" )
        return path
    }

   func getSaveFilePath(title: String, fileName: String, bookmarkKey: String) -> URL?     {
    
        var url: URL?
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
            url = savePanel.url!
   //         savePanel.url!.setBookmarkFor(key: bookmarkKey)
        }
    
    print( "getSaveFilePath: \(title),  Bookmark: \(bookmarkKey)  return: \(String(describing: url))" )
        return url
    }


    @IBAction func primesStartAction(sender: NSButton) {
        
        if let url = URL(string: primeFilePathTextField.stringValue)   {
            primeFinder = HLPrime(primesFileURL: url, delegate: self)
            
            if primesURL == nil   {
                print( "primesURL is nil" )
                
                if let url = getSaveFilePath(title: "Set Primes file path", fileName: "Primes", bookmarkKey: HLPrimesBookmarkKey)  {
                    primeFilePathTextField.stringValue = url.path
                    primesURL = getBookmarkFor(key: HLPrimesBookmarkKey)
                }
            }

            primeFinder?.findPrimes(maxPrime: HLPrimeType(terminalPrimeTextField.stringValue)!)
        }

/*       if !findPrimesInProgress {
            primeButton.title = "Running"
            nicePrimesButton.isEnabled = false

            if primesURL == nil   {
                print( "primesURL is nil" )
                
                if let path = getSaveFilePath(title: "Set Primes file path", fileName: "Primes", bookmarkKey: HLPrimesBookmarkKey)  {
                    primeFilePathTextField.stringValue = path
                    UserDefaults.standard.set(path, forKey:HLDefaultPrimeFilePathKey)
       //             primesURL = path.getBookmarkFor(key: HLPrimesBookmarkKey)
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
        
        findPrimesInProgress = !findPrimesInProgress    */
    }
    

    @IBAction func nicePrimesAction(sender: NSButton) {
/*        if !findNicePrimesInProgress {
            nicePrimesButton.title = "Running"
            findNicePrimesInProgress = true
            primeButton.isEnabled = false

            if primesURL == nil   {
                print( "primesURL is nil" )
                
                if let path = getOpenFilePath(title: "Open Primes file", bookmarkKey: HLPrimesBookmarkKey)  {
                    primeFilePathTextField.stringValue = path
                    UserDefaults.standard.set(path, forKey:HLDefaultPrimeFilePathKey)
            //        primesURL = path.getBookmarkFor(key: HLPrimesBookmarkKey)
                }
            }
            
            if nicePrimesURL == nil   {
                print( "nicePrimesURL is nil" )
                
                if let path = getSaveFilePath(title: "Set NicePrimes file path", fileName: "NicePrimes", bookmarkKey: HLNicePrimesBookmarkKey)     {
                    nicePrimeFilePathTextField.stringValue = path
                    UserDefaults.standard.set(path, forKey:HLDefaultNicePrimeFilePathKey)
              //      nicePrimesURL = path.getBookmarkFor(key: HLNicePrimesBookmarkKey)
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
        }   */
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
        primesURL?.stopAccessingSecurityScopedResource()
        nicePrimesURL?.stopAccessingSecurityScopedResource()
        
        exit(0) //  if main window closes then quit app
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressTextField.stringValue = "Idle"
        primeButton.isEnabled = false
        nicePrimesButton.isEnabled = false

        primesURL = getBookmarkFor(key: HLPrimesBookmarkKey)
        if let url = primesURL {
            primeFilePathTextField.stringValue = url.path
            primeButton.isEnabled = true
        }

        if let nicePrimeFilePath = UserDefaults.standard.string(forKey: HLDefaultNicePrimeFilePathKey)  {
            nicePrimesURL = getBookmarkFor(key: HLNicePrimesBookmarkKey)
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
    }
}


//  URL Bookmark get and set helpers
extension ViewController {

    func getBookmarkFor(key: String) -> URL?   {
        var url: URL?
        if let data = UserDefaults.standard.data(forKey: key)  {
            do  {
                var isStale = false
                    url = try URL(resolvingBookmarkData: data, options: URL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                    let success = url!.startAccessingSecurityScopedResource()

                    if !success {
                        print("startAccessingSecurityScopedResource-  success: \(success)")
                    }
                } catch {
                    print("Warning:  Unable to optain security bookmark for key: \(key) with error: \(error)!")
                }
        }
        return url
    }

    func setBookmarkFor(key: String, url: URL) {
        do  {
            let data = try url.bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(data, forKey:key)
        }   catch   {
            print("Warning:  Unable to create security bookmark for key: \(key) with error: \(error)!")
        }
    }
}

