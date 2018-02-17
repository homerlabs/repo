//
//  WKWebViewWrapper.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 2/16/18.
//  Copyright © 2018 Matthew Homer. All rights reserved.
//

import Cocoa
import WebKit

class WKWebViewWrapper : NSObject, WKScriptMessageHandler{

    let wkWebView : WKWebView
    let eventNames = ["imagechanged", "documentReady"]
    var eventFunctions : Dictionary<String, (String)->Void> = Dictionary<String, (String)->Void>()


    func setUpPlayerAndEventDelegation(){

        let controller = WKUserContentController()
        wkWebView.configuration.userContentController = controller

        for eventname in eventNames {
            controller.add(self, name: eventname)
            eventFunctions[eventname] = { _ in }
            wkWebView.evaluateJavaScript("$(#tyler_durden_image).on('imagechanged', function(event, isSuccess) { window.webkit.messageHandlers.\(eventname).postMessage(JSON.stringify(isSuccess)) }", completionHandler: nil)
        }
    }
    
    init(forWebView webView : WKWebView){
        wkWebView = webView
        super.init()
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let contentBody = message.body as? String{
            if let eventFunction = eventFunctions[message.name]{
                eventFunction(contentBody)
            }
        }
    }
}
