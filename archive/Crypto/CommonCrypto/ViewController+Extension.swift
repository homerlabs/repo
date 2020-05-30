//
//  ViewController+Extension.swift
//  
//
//  Created by Matthew Homer on 8/18/19.
//

import Cocoa
import Foundation

//  URL Bookmark get and set helpers
extension ViewController {

    func displayAlert(title: String, message: String)     {
        let a: NSAlert = NSAlert()
        a.messageText = title
        a.informativeText = message
        a.addButton(withTitle: "OK")
        a.alertStyle = NSAlert.Style.warning

        a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse: NSApplication.ModalResponse) -> Void in
            if(modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn){
                print("Bad data value.")
            }
        })
    }
}
