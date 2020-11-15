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
    var solver = HLSolver()

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
        var data = HLSudokuCell.createValidSolvedPuzzle()
        for index in 0..<HLSolver.numberOfCells {
            if (index % 10) == 0    {
                let cellData = HLSudokuCell(data: HLSolver.fullSet, status: .unsolvedStatus)
                data[index] = cellData
            }
        }
        
        let solver = HLSolver()
        solver.dataSet = data

        //  test row prune
        solver.prunePuzzle(rows: true, columns: false, blocks: false)
        XCTAssert(solver.unsolvedCount() == 0, "Pass")
        
        //  test column prune
        solver.dataSet = data
        solver.prunePuzzle(rows: false, columns: true, blocks: false)
        XCTAssert(solver.unsolvedCount() == 0, "Pass")
    }
    
    func testNewPuzzle() {
        let request = URLRequest(url: HLSolver.websudokuURL)
        hlWebView.load(request)
    }
    
    func testIsPuzzleValid() {
        let solver = HLSolver()
        var data = HLSudokuCell.createValidSolvedPuzzle()
        solver.dataSet = data
        XCTAssert(solver.isValidPuzzle(), "Pass")
        
        data[0] = HLSudokuCell(data: Set(["6"]), status: .givenStatus)   //  should be 1
        solver.dataSet = data
        XCTAssert(!solver.isValidPuzzle(), "Pass")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("SudokuSolverTests-  webView-  didFinish")
        webView.evaluateJavaScript("document.documentElement.innerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
        //        print( "innerHTML: \(String(describing: html))" )
            
                if let puzzleString = html as? String   {
                    if let solver = HLPuzzleViewModel.parseHTMLString(html: puzzleString) {
                        self.solver = solver
                    }
                }
        })
    }
}
