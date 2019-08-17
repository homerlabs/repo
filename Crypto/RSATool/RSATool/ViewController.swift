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
    var plainTextURL: URL?
    var cipherTextURL: URL?
    var deCipherTextURL: URL?

    let HLDefaultCharacterSetKey        = "CharacterSetKey"
    let HLDefaultPrimePKey              = "PrimePKey"
    let HLDefaultPrimeQKey              = "PrimeQKey"
    let HLDefaultPublicKey              = "HLPublicKey"
    
    let HLPlaintextBookmarkKey          = "PlaintextBookmarkKey"
    let HLCiphertextBookmarkKey         = "CiphertextBookmarkKey"
    let HLDeCiphertextBookmarkKey       = "DeCiphertextBookmarkKey"
   
    @IBAction func setPlaintextPathAction(sender: NSButton) {
        plainTextURL = getOpenFilePath(title: "Open Plaintext file", bookmarkKey: HLPlaintextBookmarkKey)
        guard let url = plainTextURL else { return }

        plaintextFilePathTextField.stringValue = url.path
        UserDefaults.standard.set(url, forKey: HLPlaintextBookmarkKey)
    }

    @IBAction func setCiphertextPathAction(sender: NSButton) {
        cipherTextURL = getSaveFilePath(title: "HLCrypto Save Panel", message: "Set Ciphertext file path", fileName: "Ciphertext", bookmarkName: HLCiphertextBookmarkKey)
        guard let url = cipherTextURL else { return }

        ciphertextFilePathTextField.stringValue = url.path
        UserDefaults.standard.set(url, forKey: HLCiphertextBookmarkKey)
    }

    @IBAction func setDeCiphertextPathAction(sender: NSButton) {
        deCipherTextURL = getSaveFilePath(title: "HLCrypto Save Panel", message: "Set DeCiphertext file path", fileName: "DeCiphertext", bookmarkName: HLDeCiphertextBookmarkKey)
        guard let url = deCipherTextURL else { return }

        deCiphertextFilePathTextField.stringValue = url.path
        UserDefaults.standard.set(url, forKey: HLDeCiphertextBookmarkKey)
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
            cipherTextURL = getOpenFilePath(title: "Open Ciphertext file", bookmarkKey: HLCiphertextBookmarkKey)
            ciphertextFilePathTextField.stringValue = cipherTextURL!.path
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
//        print( "ViewController-  viewDidDisappear" )
        
        plainTextURL?.stopAccessingSecurityScopedResource()
        cipherTextURL?.stopAccessingSecurityScopedResource()
        deCipherTextURL?.stopAccessingSecurityScopedResource()
        
        exit(0) //  if main window closes then quit app
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

        plainTextURL = getBookmarkFor(key: HLPlaintextBookmarkKey)
        if plainTextURL != nil  {
            plaintextFilePathTextField.stringValue = plainTextURL!.path
        }

        cipherTextURL = getBookmarkFor(key: HLCiphertextBookmarkKey)
        if cipherTextURL != nil  {
            ciphertextFilePathTextField.stringValue = cipherTextURL!.path
        }

        deCipherTextURL = getBookmarkFor(key: HLDeCiphertextBookmarkKey)
        if deCipherTextURL != nil  {
            deCiphertextFilePathTextField.stringValue = deCipherTextURL!.path
        }

        setupRSA()
   }
}

//  URL Bookmark get and set helpers
extension ViewController {
    
   func getOpenFilePath(title: String, bookmarkKey: String) -> URL?     {
    
        var url: URL?
        let openPanel = NSOpenPanel();
        openPanel.canCreateDirectories = true;
        openPanel.allowedFileTypes = ["txt"];
        openPanel.showsTagField = false;
        openPanel.prompt = "Open";
        openPanel.message = title;

        let i = openPanel.runModal();
        if(i == NSApplication.ModalResponse.OK){
            url = openPanel.url
        }
    
        print("getOpenFilePath: \(title), Bookmark: \(bookmarkKey), return: \(String(describing: url))")
        return url
    }
   
   func getSaveFilePath(title: String, message: String, fileName: String, bookmarkName: String) -> URL?     {
    
        var url: URL?
        let savePanel = NSSavePanel();
        savePanel.canCreateDirectories = true;
        savePanel.title = title;
        savePanel.nameFieldStringValue = fileName;
        savePanel.showsTagField = false;
        savePanel.prompt = "Create";
        savePanel.message = message;
        savePanel.nameFieldLabel = "Save As:";
        savePanel.allowedFileTypes = ["txt"];

        let i = savePanel.runModal();
        if(i == NSApplication.ModalResponse.OK) {
            url = savePanel.url
            setBookmarkFor(key: bookmarkName, url: url!)
        }
    
        return url
    }
    func getBookmarkFor(key: String) -> URL?   {
        var url: URL? = nil
        
        if let data = UserDefaults.standard.data(forKey: key)  {
            do  {
                var isStale = false
                    url = try URL(resolvingBookmarkData: data, options: URL.BookmarkResolutionOptions.withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                    let success = url!.startAccessingSecurityScopedResource()

                    if !success {
                        print("startAccessingSecurityScopedResource-  success: \(success)")
                    }
                } catch {
     //               print("Warning:  Unable to optain security bookmark for key: \(key) with error: \(error)!")
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

