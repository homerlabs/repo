//
//  ViewController.swift
//  RSATool
//
//  Created by Matthew Homer on 10/19/17.
//  Copyright © 2017 Matthew Homer. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSControlTextEditingDelegate {

    @IBOutlet var plaintextFilePathTextField: NSTextField!
    @IBOutlet var ciphertextFilePathTextField: NSTextField!
    @IBOutlet var primePTextField: NSTextField!
    @IBOutlet var primeQTextField: NSTextField!
    @IBOutlet var publicKeyTextField: NSTextField!
    @IBOutlet var privateKeyTextField: NSTextField!
    @IBOutlet var nTextField: NSTextField!
    @IBOutlet var gammaTextField: NSTextField!
    @IBOutlet var encodeButton: NSButton!
    @IBOutlet var decodeButton: NSButton!

    var rsa: HLRSA!
    let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
    let HLDefaultPlaintextFilePathKey   = "PlaintextPathKey"
    let HLPlaintextBookmarkKey          = "PlaintextBookmarkKey"
    let HLCiphertextBookmarkKey         = "CiphertextBookmarkKey"
    let HLDefaultPrimePKey              = "PrimePKey"
    let HLDefaultPrimeQKey              = "PrimeQKey"
    let HLDefaultPublicKeyKey           = "PublicKey"
    
    
   func getOpenFilePath(title: String) -> String     {
        print("getOpenFilePath")
    
        var path = ""
        let openPanel = NSOpenPanel();
        openPanel.canCreateDirectories = true;
        openPanel.title = "Prime Finder Open Panel";
//        openPanel.nameFieldStringValue = "Primes";
        openPanel.allowedFileTypes = ["txt"];
        openPanel.showsTagField = false;
        openPanel.prompt = "Open";
        openPanel.message = "Prime Finder Open Panel";
//        openPanel.nameFieldLabel = "Save As:";

        let i = openPanel.runModal();
        if(i == NSApplication.ModalResponse.OK){
            path = openPanel.url!.path
            openPanel.url!.setBookmarkFor(key: HLPlaintextBookmarkKey)
        }
    
        return path
    }
   
   func getSaveFilePath(title: String) -> String     {
        print("getSaveFilePath")
    
        var path = ""
        let savePanel = NSSavePanel();
        savePanel.canCreateDirectories = true;
        savePanel.title = "Save Panel";
        savePanel.nameFieldStringValue = "Ciphertext";
        savePanel.showsTagField = false;
        savePanel.prompt = "Create";
        savePanel.message = title;
        savePanel.nameFieldLabel = "Save As:";
        savePanel.allowedFileTypes = ["txt"];

        let i = savePanel.runModal();
        if(i == NSApplication.ModalResponse.OK){
            path = savePanel.url!.path
            savePanel.url!.setBookmarkFor(key: HLCiphertextBookmarkKey)
        }
        return path
    }
   
    @IBAction func decodeAction(sender: NSButton) {
 //       print( "ViewController-  decodeAction" )
//        let url = URL(fileURLWithPath: plaintextFilePathTextField.stringValue)
//        rsa.encodeFile(plaintextURL: url)
        print( "rsa.decodeFile completed." )
    }


    @IBAction func setPlaintextPathAction(sender: NSButton) {
        print( "setPlaintextPathAction" )
        let path = getOpenFilePath(title: "Set Plaintext file path")
        plaintextFilePathTextField.stringValue = path
        
        if !ciphertextFilePathTextField.stringValue.isEmpty   {
            encodeButton.isEnabled = true
        }
    }


    @IBAction func setCiphertextPathAction(sender: NSButton) {
        print( "setCiphertextPathAction" )
        let path = getSaveFilePath(title: "Set Ciphertext file path")
        ciphertextFilePathTextField.stringValue = path
        
        if !plaintextFilePathTextField.stringValue.isEmpty   {
            encodeButton.isEnabled = true
        }
    }


    @IBAction func encodeAction(sender: NSButton) {
 //       print( "ViewController-  encodeAction" )
        rsa.encodeFile(inputFilepath: plaintextFilePathTextField.stringValue, outputFilepath: ciphertextFilePathTextField.stringValue)
        print( "rsa.encodeFile completed." )
    }


     func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool    {
        print( "ViewController-  textShouldEndEditing-  control: \(control.stringValue)" )
        
/*        if control == plaintextFilePathTextField    {
            var newValue = control.stringValue
            if !newValue.hasPrefix("/")  {
                newValue = homeDir + "/" + newValue
            }
           UserDefaults.standard.set(newValue, forKey:HLDefaultPlaintextFilePathKey)
        }   */
        
        if control == primePTextField    {
            setupRSA()
            UserDefaults.standard.set(primePTextField.stringValue, forKey:HLDefaultPrimePKey)
        }

        else if control == primeQTextField    {
            setupRSA()
            UserDefaults.standard.set(primeQTextField.stringValue, forKey:HLDefaultPrimeQKey)
        }

        else if control == publicKeyTextField    {
            setupKeys()
        }

        else    {   assert( false )     }
        
        UserDefaults.standard.synchronize()
        return true
    }
    
    func setupKeys()    {
        let publicKey = Int64(publicKeyTextField.stringValue)!
        let privateKey = rsa.calculateKey(publicKey: publicKey)
        privateKeyTextField.stringValue = String(privateKey)
        UserDefaults.standard.set(publicKeyTextField.stringValue, forKey:HLDefaultPublicKeyKey)
        rsa.keyPublic = publicKey
        rsa.keyPrivate = privateKey
    }
    
    
    func setupRSA() {
        let p = Int64(primePTextField.stringValue)!
        let q = Int64(primeQTextField.stringValue)!
        let n = p * q
        let gamma = (p-1) * (q-1)
        nTextField.stringValue = String(n)
        gammaTextField.stringValue = String(gamma)
        rsa = HLRSA(p: p, q: q)
        setupKeys()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let plaintextFilePath = UserDefaults.standard.string(forKey: HLDefaultPlaintextFilePathKey)  {
            if let url = plaintextFilePathTextField.stringValue.getBookmarkFor(key: HLPlaintextBookmarkKey) {
                plaintextFilePathTextField.stringValue = plaintextFilePath
                print( "ViewController-  viewDidLoad-  url: \(String(describing: url))" )
            }
        }
        else    {
            plaintextFilePathTextField.stringValue = "Desktop/Plaintext???"
        }

        if let primeP = UserDefaults.standard.string(forKey: HLDefaultPrimePKey)  {
            primePTextField.stringValue = primeP
        }
        else    {
            primePTextField.stringValue = "13"
        }

        if let primeQ = UserDefaults.standard.string(forKey: HLDefaultPrimeQKey)  {
            primeQTextField.stringValue = primeQ
        }
        else    {
            primeQTextField.stringValue = "17"
        }

        if let publicKey = UserDefaults.standard.string(forKey: HLDefaultPublicKeyKey)  {
            publicKeyTextField.stringValue = publicKey
        }
        else    {
            publicKeyTextField.stringValue = "107"
        }

        setupRSA()
        encodeButton.isEnabled = false
        decodeButton.isEnabled = false
   }
}

