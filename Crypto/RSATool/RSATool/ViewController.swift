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
        print( "ViewController-  encodeAction" )
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
            UserDefaults.standard.set(publicKeyTextField.stringValue, forKey:HLDefaultPublicKeyKey)
        }

        else    {   assert( false )     }
        
        UserDefaults.standard.synchronize()
        return true
    }
    
    
    func setupRSA() {
        let p = Int64(primePPathTextField.stringValue)!
        let q = Int64(primeQPathTextField.stringValue)!
        let n = p * q
        let gamma = (p-1) * (q-1)
        nTextField.stringValue = String(n)
        gammaTextField.stringValue = String(gamma)

        rsa = HLRSA(p: p, q: q)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRSA()
 //       let lcm = LCM(lcmA: 10, lcmB: 20)
        let result = rsa.fastExpOf(a: 7, exp: 560, mod: 561)
        print( "result: \(result)" )
    }
}

