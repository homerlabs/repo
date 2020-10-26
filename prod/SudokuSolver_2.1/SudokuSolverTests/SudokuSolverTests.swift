//
//  SudokuSolverTests.swift
//  SudokuSolverTests
//
//  Created by Matthew Homer on 3/23/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import XCTest
import WebKit
@testable import HLSudokuSolver

class SudokuSolverTests: XCTestCase, WKNavigationDelegate {

    var hlWebView = WKWebView()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    //  dataset used by testPrunePuzzle()
    //  0, 2, 3, 4, 5, 6, 7, 8, 9,
    //  2, 0, 4, 5, 6, 7, 8, 9, 1,
    //  3, 4, 0, 6, 7, 8, 9, 1, 2,
    //  4, 5, 6, 0, 8, 9, 1, 2, 3,
    //  5, 6, 7, 8, 0, 1, 2, 3, 4,
    //  6, 7, 8, 9, 1, 0, 3, 4, 5,
    //  7, 8, 9, 1, 2, 3, 0, 5, 6,
    //  8, 9, 1, 2, 3, 4, 5, 0, 7,
    //  9, 1, 2, 3, 4, 5, 6, 7, 0
    func testPrunePuzzle() {
        var data = createValidSolvedPuzzle()
        for index in 0..<81 {
            if (index % 10) == 0    { data[index] = "0" }
        }
        
        let solver = HLSolver()
        solver.load(data)
        solver.prunePuzzle(rows: true, columns: false, blocks: false)
        XCTAssert(solver.unsolvedCount() == 0, "Pass")
        
        solver.load(data)
        solver.prunePuzzle(rows: false, columns: true, blocks: false)
        XCTAssert(solver.unsolvedCount() == 0, "Pass")
    }
    
    func testNewPuzzle() {
        let request = URLRequest(url: HLSolver.websudokuURL)
        hlWebView.load(request)
    }
    
    func testIsPuzzleValid() {
        let solver = HLSolver()
        var data = createValidSolvedPuzzle()
        solver.load(data)
        XCTAssert(solver.isValidPuzzle(), "Pass")
        
        data[0] = "6"   //  should be 1
        solver.load(data)
        XCTAssert(!solver.isValidPuzzle(), "Pass")
    }

    //  dataset created by createValidSolvedPuzzle()
    //  1, 2, 3, 4, 5, 6, 7, 8, 9,
    //  2, 3, 4, 5, 6, 7, 8, 9, 1,
    //  3, 4, 5, 6, 7, 8, 9, 1, 2,
    //  4, 5, 6, 7, 8, 9, 1, 2, 3,
    //  5, 6, 7, 8, 9, 1, 2, 3, 4,
    //  6, 7, 8, 9, 1, 2, 3, 4, 5,
    //  7, 8, 9, 1, 2, 3, 4, 5, 6,
    //  8, 9, 1, 2, 3, 4, 5, 6, 7,
    //  9, 1, 2, 3, 4, 5, 6, 7, 8
    func createValidSolvedPuzzle() -> [String] {
        var data = Array(repeating: "0", count: 81)
        
        for row in 0..<9 {
            for column in 0..<9 {
                data[row*9+column] = String((column+row) % 9 + 1)
            }
        }
        return data
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("HLSolverViewController-  webView-  didFinish")
        webView.evaluateJavaScript("document.documentElement.innerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
        //        print( "innerHTML: \(String(describing: html))" )
            
                if let puzzleString = html as? String   {
                    let solver = HLSolver(html: puzzleString)
             //       self.unsolvedNodeCount = self.solver.unsolvedCount()
                }
        })
    }
}
