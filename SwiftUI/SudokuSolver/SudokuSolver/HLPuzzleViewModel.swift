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

    @Published var data: [Set<String>] = Array(repeating: ["1", "2"], count: 81)
    @Published var status: [HLCellStatus] = Array(repeating: HLCellStatus.givenStatus, count: 81)
    @Published var puzzleName = "Puzzle not found"
    @Published var puzzleState = HLPuzzleState.initial

    let url = URL(string: "https://nine.websudoku.com/?level=4")!
    var solver = HLSolver()
    var hlWebView = WKWebView()

    func getNewPuzzle() {
        print("getNewPuzzle")
   //     solveButton.setTitle("Prune", for: .normal)
   //     solver = HLSolver()
  //      updateDisplay()
        
        let request = URLRequest(url: url)
        hlWebView = WKWebView(frame:CGRect(x: 0, y: 0, width: 1000, height: 1000))
        hlWebView.navigationDelegate = self
        hlWebView.load(request)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("HLSolverViewController-  webView-  didFinish")
        webView.evaluateJavaScript("document.documentElement.innerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
        //        print( "innerHTML: \(String(describing: html))" )
            
                if let puzzleString = html as? String   {
                    self.solver = HLSolver(html: puzzleString)
                    
                    var tempData: [Set<String>] = Array(repeating: [], count: 81)
                    for index in 0..<self.solver.dataSet.grid.count {
                        (tempData[index], self.status[index]) = self.solver.dataSet.grid[index]
                    }
                    self.data = tempData
                    
        //           print( "puzzleString: \(puzzleString)" )
           //         self.updateDisplay()
            //        self.undoButton.isEnabled = false
            //        self.solveButton.isEnabled = true
                }
        })
    }

    override init() {
        print("HLPuzzleViewModel-  init")
        super.init()
        getNewPuzzle()
    }
}
