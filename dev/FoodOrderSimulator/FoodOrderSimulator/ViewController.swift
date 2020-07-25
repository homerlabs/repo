//
//  ViewController.swift
//  DeliveryOrders
//
//  Created by Matthew Homer on 7/6/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var button: NSButton!
    
    let simulator: OrderSimulator = OrderSimulator()

    override func viewDidLoad() {
        super.viewDidLoad()
        //  just a touch of customization
        self.view.setValue(NSColor(red: 0.8, green: 0.9, blue: 0.95, alpha: 0.5), forKey: "backgroundColor")
        button.setValue(NSColor.white, forKey: "backgroundColor")
            
        simulator.simulatorSetup()
   }
   
   @IBAction func buttonAction(sender: NSButton) {
        simulator.shelfManager.verboseDebug.toggle()
        
        if simulator.shelfManager.verboseDebug {
            button.title = "Stop Verbose Mode"
        }
        else {
            button.title = "Start Verbose Mode"
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

