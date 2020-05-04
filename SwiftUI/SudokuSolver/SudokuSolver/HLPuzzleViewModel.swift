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

    @Published var solver = HLSolver()
    @Published var puzzleState = HLPuzzleState.initial
    @Published var algorithmSelected: HLAlgorithmMode = .monoCell
    @Published var unsolvedNodeCount = 0
    @Published var testRows = true
    @Published var testColumns = true
    @Published var testBlocks = true
    
    let hlKeySettingRow = "hlKeySettingRow"
    let hlKeySettingColumn = "hlKeySettingColumn"
    let hlKeySettingBlock = "hlKeySettingBlock"
    let hlKeySettingAlgorithm = "hlKeySettingAlgorithm"

    let url = URL(string: "https://nine.websudoku.com/?level=4")!
    var hlWebView = WKWebView()
    
    func solveAction() {
        if puzzleState == .initial {
            puzzleState = .solving
            solver.prunePuzzle(rows: true, columns: true, blocks: true)
        }
        else {
            switch algorithmSelected {
                case HLAlgorithmMode.monoCell:
                    solver.findMonoCells(rows: testRows, columns: testBlocks)
                
                case HLAlgorithmMode.findSets:
                    solver.findPuzzleSets(rows: testRows, columns: testColumns, blocks: testBlocks)
                
                case HLAlgorithmMode.monoSector:
                    solver.findMonoSectors(rows: testRows, columns: testColumns)
            }
        }
            
        unsolvedNodeCount = solver.unsolvedCount()
    }
    
    func saveSetting() {
        //  by negating the returned value we change the default to true
        UserDefaults.standard.set(!testRows, forKey: hlKeySettingRow)
        UserDefaults.standard.set(!testColumns, forKey: hlKeySettingColumn)
        UserDefaults.standard.set(!testBlocks, forKey: hlKeySettingBlock)
        UserDefaults.standard.set(algorithmSelected.rawValue, forKey: hlKeySettingAlgorithm)
    }
    
    func getNewPuzzle() {
        puzzleState = HLPuzzleState.initial
    //    puzzleName = ""
        let request = URLRequest(url: url)
        hlWebView.load(request)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("HLSolverViewController-  webView-  didFinish")
        webView.evaluateJavaScript("document.documentElement.innerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
        //        print( "innerHTML: \(String(describing: html))" )
            
                if let puzzleString = html as? String   {
                    self.solver = HLSolver(html: puzzleString)
                    self.unsolvedNodeCount = self.solver.unsolvedCount()
           //         self.updateDisplay()
            //        self.undoButton.isEnabled = false
            //        self.solveButton.isEnabled = true
                }
        })
    }

    deinit {
        saveSetting()
        print("HLPuzzleViewModel-  deinit")
    }
    
    override init() {
        print("HLPuzzleViewModel-  init")
        super.init()
        
        hlWebView = WKWebView(frame:CGRect(x: 0, y: 0, width: 1000, height: 1000))
        hlWebView.navigationDelegate = self
        
        getNewPuzzle()
        
        //  by negating the returned value we change the default to true
        testRows = !UserDefaults.standard.bool(forKey: hlKeySettingRow)
        testColumns = !UserDefaults.standard.bool(forKey: hlKeySettingColumn)
        testBlocks = !UserDefaults.standard.bool(forKey: hlKeySettingBlock)
        algorithmSelected = HLAlgorithmMode(rawValue: UserDefaults.standard.integer(forKey: hlKeySettingAlgorithm))!
    }
}
