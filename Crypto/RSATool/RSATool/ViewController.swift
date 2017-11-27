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
    @IBOutlet var primePPathTextField: NSTextField!
    @IBOutlet var primeQPathTextField: NSTextField!
    @IBOutlet var publicKeyTextField: NSTextField!
    @IBOutlet var privateKeyTextField: NSTextField!
    @IBOutlet var nTextField: NSTextField!
    @IBOutlet var gammaTextField: NSTextField!

    var rsa: HLRSA!
    let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
    let HLDefaultPlaintextFilePathKey = "PlaintextPathKey"
    let HLDefaultPrimePKey = "PrimePKey"
    let HLDefaultPrimeQKey = "PrimeQKey"
    let HLDefaultPublicKeyKey = "PublicKey"


    @IBAction func encodeAction(sender: NSButton) {
 //       print( "ViewController-  encodeAction" )
        let url = URL(fileURLWithPath: plaintextFilePathTextField.stringValue)
        rsa.encodeFile(plaintextURL: url)
        print( "rsa.encodeFile completed." )
    }


     func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool    {
        print( "ViewController-  textShouldEndEditing-  control: \(control.stringValue)" )
        
        if control == plaintextFilePathTextField    {
            var newValue = control.stringValue
            if !newValue.hasPrefix("/")  {
                newValue = homeDir + "/" + newValue
            }
           UserDefaults.standard.set(newValue, forKey:HLDefaultPlaintextFilePathKey)
        }
        
        else if control == primePPathTextField    {
            setupRSA()
            UserDefaults.standard.set(primePPathTextField.stringValue, forKey:HLDefaultPrimePKey)
        }

        else if control == primeQPathTextField    {
            setupRSA()
            UserDefaults.standard.set(primeQPathTextField.stringValue, forKey:HLDefaultPrimeQKey)
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
        let p = Int64(primePPathTextField.stringValue)!
        let q = Int64(primeQPathTextField.stringValue)!
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
            plaintextFilePathTextField.stringValue = plaintextFilePath
        }
        else    {
            plaintextFilePathTextField.stringValue = "Desktop/Plaintext"
        }

        if let primeP = UserDefaults.standard.string(forKey: HLDefaultPrimePKey)  {
            primePPathTextField.stringValue = primeP
        }
        else    {
            primePPathTextField.stringValue = "13"
        }

        if let primeQ = UserDefaults.standard.string(forKey: HLDefaultPrimeQKey)  {
            primeQPathTextField.stringValue = primeQ
        }
        else    {
            primeQPathTextField.stringValue = "17"
        }

        if let publicKey = UserDefaults.standard.string(forKey: HLDefaultPublicKeyKey)  {
            publicKeyTextField.stringValue = publicKey
        }
        else    {
            publicKeyTextField.stringValue = "107"
        }

        setupRSA()
   }
}

