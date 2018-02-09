//
//  ViewController.swift
//  RSATool
//
//  Created by Matthew Homer on 10/19/17.
//  Copyright © 2017 Matthew Homer. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSControlTextEditingDelegate {

    let defaultPrimeP: String = "257"
    let defaultPrimeQ = "251"
    let defaultPublicKey = "36083"
    let defaultCharacterSet = "-ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+*/"

    @IBOutlet var plaintextFilePathTextField: NSTextField!
    @IBOutlet var ciphertextFilePathTextField: NSTextField!
    @IBOutlet var deCiphertextFilePathTextField: NSTextField!
    
    @IBOutlet var primePTextField: NSTextField!
    @IBOutlet var primeQTextField: NSTextField!
    @IBOutlet var publicKeyTextField: NSTextField!
    @IBOutlet var privateKeyTextField: NSTextField!
    @IBOutlet var nTextField: NSTextField!
    @IBOutlet var gammaTextField: NSTextField!
    @IBOutlet var characterSetTextField: NSTextField!
    @IBOutlet var characterSetSizeTextField: NSTextField!
    @IBOutlet var chunkSizeTextField: NSTextField!

    @IBOutlet var encodeButton: NSButton!
    @IBOutlet var decodeButton: NSButton!

    var rsa: HLRSA!
    let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
    var plainTextURL: URL? = nil
    var cipherTextURL: URL? = nil
    var deCipherTextURL: URL? = nil

    let HLDefaultPlaintextFilePathKey   = "PlaintextPathKey"
    let HLDefaultCiphertextFilePathKey  = "CiphertextPathKey"
    let HLDefaultDeCiphertextFilePathKey = "DeCiphertextPathKey"

    let HLDefaultCharacterSetKey        = "CharacterSetKey"
    let HLDefaultPrimePKey              = "PrimePKey"
    let HLDefaultPrimeQKey              = "PrimeQKey"
    let HLDefaultPublicKey              = "HLPublicKey"
    
    let HLPlaintextBookmarkKey          = "PlaintextBookmarkKey"
    let HLCiphertextBookmarkKey         = "CiphertextBookmarkKey"
    let HLDeCiphertextBookmarkKey       = "DeCiphertextBookmarkKey"

    
   func getOpenFilePath(title: String, bookmarkKey: String) -> String     {
    
        var path = ""
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
    
        return path
    }
   
   func getSaveFilePath(title: String, fileName: String, bookmarkName: String) -> String     {
    
        var path = ""
        let savePanel = NSSavePanel();
        savePanel.canCreateDirectories = true;
        savePanel.title = "RSA Tool Save Panel";
        savePanel.nameFieldStringValue = fileName;
        savePanel.showsTagField = false;
        savePanel.prompt = "Create";
        savePanel.message = title;
        savePanel.nameFieldLabel = "Save As:";
        savePanel.allowedFileTypes = ["txt"];

        let i = savePanel.runModal();
        if(i == NSApplication.ModalResponse.OK){
            path = savePanel.url!.path
            savePanel.url!.setBookmarkFor(key: bookmarkName)
        }
        return path
    }
   
    @IBAction func setPlaintextPathAction(sender: NSButton) {
        let path = getOpenFilePath(title: "Open Plaintext file", bookmarkKey: HLPlaintextBookmarkKey)
        plaintextFilePathTextField.stringValue = path
        UserDefaults.standard.set(path, forKey:HLDefaultPlaintextFilePathKey)
        plainTextURL = path.getBookmarkFor(key: HLPlaintextBookmarkKey)
    }

    @IBAction func setCiphertextPathAction(sender: NSButton) {
        let path = getSaveFilePath(title: "Set Ciphertext file path", fileName: "Ciphertext", bookmarkName: HLCiphertextBookmarkKey)
        ciphertextFilePathTextField.stringValue = path
        UserDefaults.standard.set(path, forKey:HLDefaultCiphertextFilePathKey)
        cipherTextURL = path.getBookmarkFor(key: HLCiphertextBookmarkKey)
    }

    @IBAction func setDeCiphertextPathAction(sender: NSButton) {
        let path = getSaveFilePath(title: "Set DeCiphertext file path", fileName: "DeCiphertext", bookmarkName: HLDeCiphertextBookmarkKey)
        deCiphertextFilePathTextField.stringValue = path
        UserDefaults.standard.set(path, forKey:HLDefaultDeCiphertextFilePathKey)
        deCipherTextURL = path.getBookmarkFor(key: HLDeCiphertextBookmarkKey)
    }
    
    
    @IBAction func encodeAction(sender: NSButton) {
        if plainTextURL == nil   {
            print( "plainTextURL is nil" )
            setPlaintextPathAction(sender: sender) //  wrong button but any button will do
        }
        
        if cipherTextURL == nil   {
            print( "cipherTextURL is nil" )
            setCiphertextPathAction(sender: sender) //  wrong button but any button will do
        }
        
        rsa.encodeFile(inputFilepath: plaintextFilePathTextField.stringValue, outputFilepath: ciphertextFilePathTextField.stringValue)
        print( "rsa.encodeFile completed." )
    }


    @IBAction func decodeAction(sender: NSButton) {
        if cipherTextURL == nil   {
            print( "cipherTextURL is nil" )
            let path = getOpenFilePath(title: "Open Ciphertext file", bookmarkKey: HLCiphertextBookmarkKey)
            ciphertextFilePathTextField.stringValue = path
            UserDefaults.standard.set(path, forKey:HLDefaultCiphertextFilePathKey)
            cipherTextURL = path.getBookmarkFor(key: HLCiphertextBookmarkKey)
        }
        
        if deCipherTextURL == nil   {
            print( "deCipherTextURL is nil" )
            setDeCiphertextPathAction(sender: sender) //  wrong button but any button will do
        }
        
        rsa.decodeFile(inputFilepath: ciphertextFilePathTextField.stringValue, outputFilepath: deCiphertextFilePathTextField.stringValue)
        print( "rsa.decodeFile completed." )
    }


     func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool    {
        print( "ViewController-  textShouldEndEditing-  control: \(control.stringValue)" )
        
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
            UserDefaults.standard.set(publicKeyTextField.stringValue, forKey:HLDefaultPublicKey)
        }

        else if control == characterSetTextField    {
            UserDefaults.standard.set(characterSetTextField.stringValue, forKey:HLDefaultCharacterSetKey)
            characterSetSizeTextField.integerValue = characterSetTextField.stringValue.count
            setupRSA()
        }

        else    {   assert( false )     }
        
        UserDefaults.standard.synchronize()
        return true
    }
    
    func setupKeys()    {
        let publicKey = Int64(publicKeyTextField.stringValue)!
        let privateKey = rsa.calculateKey(publicKey: publicKey)
        privateKeyTextField.stringValue = String(privateKey)
        rsa.keyPublic = publicKey
        rsa.keyPrivate = privateKey
    }
    
    
    func setupRSA() {
        let charSet = characterSetTextField.stringValue
        let p = Int64(primePTextField.stringValue)!
        let q = Int64(primeQTextField.stringValue)!
        let n = p * q
        let gamma = (p-1) * (q-1)
        nTextField.stringValue = String(n)
        gammaTextField.stringValue = String(gamma)
        rsa = HLRSA(p: p, q: q, characterSet: charSet)
        setupKeys()
        
        chunkSizeTextField.stringValue = String.init(format:" %0.1f", arguments: [rsa.chuckSizeDouble])
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        print( "ViewController-  viewDidDisappear" )
        plainTextURL?.stopAccessingSecurityScopedResource()
        cipherTextURL?.stopAccessingSecurityScopedResource()
        deCipherTextURL?.stopAccessingSecurityScopedResource()
        exit(0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let primeP = UserDefaults.standard.string(forKey: HLDefaultPrimePKey)  {
            primePTextField.stringValue = primeP
        }
        else    {
            primePTextField.stringValue = defaultPrimeP
        }

        if let primeQ = UserDefaults.standard.string(forKey: HLDefaultPrimeQKey)  {
            primeQTextField.stringValue = primeQ
        }
        else    {
            primeQTextField.stringValue = defaultPrimeQ
        }

        if let publicKey = UserDefaults.standard.string(forKey: HLDefaultPublicKey)  {
  //          NSSound(named: NSSound.Name(rawValue: "Ping"))?.play()
            publicKeyTextField.stringValue = publicKey
        }
        else    {
   //         NSSound(named: NSSound.Name(rawValue: "Purr"))?.play()
            publicKeyTextField.stringValue = defaultPublicKey
        }

        if let characterSet = UserDefaults.standard.string(forKey: HLDefaultCharacterSetKey)  {
            characterSetTextField.stringValue = characterSet
        }
        else    {
            characterSetTextField.stringValue = defaultCharacterSet
            characterSetSizeTextField.integerValue = characterSetTextField.stringValue.count
        }

        if let plaintextFilePath = UserDefaults.standard.string(forKey: HLDefaultPlaintextFilePathKey)  {
            plainTextURL = plaintextFilePath.getBookmarkFor(key: HLPlaintextBookmarkKey)
            if plainTextURL != nil {
                plaintextFilePathTextField.stringValue = plaintextFilePath
            }
        }

        if let ciphertextFilePath = UserDefaults.standard.string(forKey: HLDefaultCiphertextFilePathKey)  {
            cipherTextURL = ciphertextFilePath.getBookmarkFor(key: HLCiphertextBookmarkKey)
            if cipherTextURL != nil {
                ciphertextFilePathTextField.stringValue = ciphertextFilePath
            }
        }

        if let deCiphertextFilePath = UserDefaults.standard.string(forKey: HLDefaultDeCiphertextFilePathKey)  {
            deCipherTextURL = deCiphertextFilePath.getBookmarkFor(key: HLDeCiphertextBookmarkKey)
            if deCipherTextURL != nil {
                deCiphertextFilePathTextField.stringValue = deCiphertextFilePath
            }
        }

        setupRSA()
   }
}

