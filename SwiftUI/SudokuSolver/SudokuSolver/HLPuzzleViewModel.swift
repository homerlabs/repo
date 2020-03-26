//
//  HLPuzzleViewModel.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 3/24/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import Foundation
import WebKit

class HLPuzzleViewModel: NSObject, ObservableObject, WKNavigationDelegate {

    @Published var dataArray: [Set<String>] = Array(repeating: [], count: 81)
    @Published var statusArray: [HLCellStatus] = Array(repeating: HLCellStatus.givenStatus, count: 81)
    @Published var puzzleName = "Puzzle not found"
    @Published var puzzleState = HLPuzzleState.initial
    @Published var testRows = true
    @Published var testColumns = true
    @Published var testBlocks = true

    let url = URL(string: "https://nine.websudoku.com/?level=4")!
    var solver = HLSolver()
    var hlWebView = WKWebView()
    
    func solveAction() {
        if puzzleState == .initial {
            puzzleState = .solving
            solver.prunePuzzle(rows: true, columns: true, blocks: true)
            tempXFerData()
        }
    }
    
    func tempXFerData() {
        var tempData: [Set<String>] = Array(repeating: [], count: 81)
        for index in 0..<self.solver.dataSet.grid.count {
            (tempData[index], self.statusArray[index]) = self.solver.dataSet.grid[index]
        }
        self.dataArray = tempData
    }

    func getNewPuzzle() {
        puzzleState = HLPuzzleState.initial
        puzzleName = ""
        let request = URLRequest(url: url)
        hlWebView.load(request)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("HLSolverViewController-  webView-  didFinish")
        webView.evaluateJavaScript("document.documentElement.innerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
        //        print( "innerHTML: \(String(describing: html))" )
            
                if let puzzleString = html as? String   {
                    self.solver = HLSolver(html: puzzleString)
                    self.tempXFerData()
                    self.puzzleName = self.solver.puzzleName
                    
           //         self.updateDisplay()
            //        self.undoButton.isEnabled = false
            //        self.solveButton.isEnabled = true
                }
        })
    }

    override init() {
        print("HLPuzzleViewModel-  init")
        super.init()
        
        hlWebView = WKWebView(frame:CGRect(x: 0, y: 0, width: 1000, height: 1000))
        hlWebView.navigationDelegate = self
        
        getNewPuzzle()
    }
}
