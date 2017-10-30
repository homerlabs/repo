//
//  ViewController.swift
//  RSATool
//
//  Created by Matthew Homer on 10/19/17.
//  Copyright © 2017 Matthew Homer. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    let rsa = HLRSA(p: 7, q: 11)


    override func viewDidLoad() {
        super.viewDidLoad()

 //       let lcm = LCM(lcmA: 10, lcmB: 20)
        let result = rsa.fastExpOf(a: 7, exp: 560, mod: 561)
        print( "result: \(result)" )
    }
}

