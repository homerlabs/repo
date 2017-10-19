//
//  ViewController.swift
//  RSATool
//
//  Created by Matthew Homer on 10/19/17.
//  Copyright © 2017 Matthew Homer. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    func LCM(lcmA: Int64, lcmB: Int64) -> Int64 {
        print( "lcmA: \(lcmA)   lcmB: \(lcmB)" )
    
        return 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let lcm = LCM(lcmA: 10, lcmB: 20)
        print( "lcm: \(lcm)" )
    }
}

