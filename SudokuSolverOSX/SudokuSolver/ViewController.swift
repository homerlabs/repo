//
//  ViewController.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 2/15/18.
//  Copyright © 2018 Matthew Homer. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController, WKNavigationDelegate {

    let urlString = "https://nine.websudoku.com/?"
//    let urlString = "https://websudoku.com/?"
    var webView: WKWebView!
    var puzzleArray = Array(repeating: 0, count: 81)
    var puzzle = HLSolver()
    
    
    func parsePuzzle(data: String)  {
        var puzzleString = data

        if let range: Range<String.Index> = puzzleString.range(of:"<form")  {
            puzzleString = String(puzzleString[range.lowerBound...])
    //        print( "*******************puzzleString: \(puzzleString)" )
            
            for index in 0..<81 {
                if let range: Range<String.Index> = puzzleString.range(of:"</td>")  {
                    let preString = puzzleString[puzzleString.startIndex...range.upperBound]
       //             print( "*******************preString: \(preString)" )
                    puzzleString.removeFirst(preString.count)
                    
                    if let range: Range<String.Index> = preString.range(of:"value=\"")  {
                        if let value = Int(String(preString[range.upperBound])) {
                            print( "valueString: \(value)" )
                            puzzleArray[index] = value
                        }
                    }
                }
            }
            
            print( "puzzleString: \(puzzleString)" )
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print( "didFinishNavigationdidFinishNavigation" )
        
        webView.evaluateJavaScript("document.documentElement.innerHTML.toString()",
                                   completionHandler: { (html: Any?, error: Error?) in
           //     print( "innerHTML: \(String(describing: html))" )
                
                if let puzzleString = html as? String   {
                    self.parsePuzzle(data: puzzleString)
                }
        })
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        let webConfiguration = WKWebViewConfiguration()
    
        webView = WKWebView(frame: view.frame, configuration: webConfiguration)
//        webView.uiDelegate = self
        webView.navigationDelegate = self

        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url));
            view = webView
        }
    }

/*    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }   */
}

