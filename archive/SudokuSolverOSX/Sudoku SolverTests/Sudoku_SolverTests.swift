//
//  Sudoku_SolverTests.swift
//  Sudoku SolverTests
//
//  Created by Matthew Homer on 1/25/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import XCTest
import WebKit

class Sudoku_SolverTests: XCTestCase, WKNavigationDelegate {
    var puzzle = HLSolver()
    var webView: WKWebView!

    func fetchPuzzle(url: URL)   {
        print( "fetchPuzzle: \(url)" )
        puzzle = HLSolver() //  create and display a blank puzzle (all nodes unsolved)
//        updateDisplay()
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 10, height: 10))
        webView = WKWebView(frame: view.frame)
        webView.navigationDelegate = self
        webView.load(URLRequest(url: url));
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print( "WKNavigationDelegate-  didFinish" )
        
        webView.evaluateJavaScript("document.documentElement.innerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
                print( "innerHTML: \(String(describing: html))" )
                
                if let puzzleString = html as? String   {
                    self.puzzle = HLSolver(html: puzzleString)
       //             self.puzzleNameTextField.stringValue = self.puzzle.puzzleName
       //             self.updateDisplay()
                }
        })
    }

    override func setUp() {
        fetchPuzzle(url: puzzle.url)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let isValid = puzzle.isValidPuzzle()
        XCTAssert(isValid, "not valid")
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
