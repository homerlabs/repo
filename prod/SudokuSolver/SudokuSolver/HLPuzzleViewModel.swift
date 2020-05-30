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
    @Published var algorithmSelected: HLAlgorithmMode = .monoCell
    @Published var unsolvedNodeCount = 0
    @Published var testRows = true
    @Published var testColumns = true
    @Published var testBlocks = true
    @Published var undoButtonEnabled = false
    @Published var previousState = HLPuzzleState.initial
    
    let hlKeySettingRow         = "hlKeySettingRow"
    let hlKeySettingColumn      = "hlKeySettingColumn"
    let hlKeySettingBlock       = "hlKeySettingBlock"
    let hlKeySettingAlgorithm   = "hlKeySettingAlgorithm"

    var hlWebView = WKWebView()
    
    func solveAction() {
        solver.previousDataSet = solver.dataSet
        previousState = solver.puzzleState  //  needed for the Undo button after initial Prune operation
        
        if solver.puzzleState == .initial {
            solver.prunePuzzle(rows: true, columns: true, blocks: true)
            solver.markSolvedCells()
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
            
            solver.updateChangedCells()
       }
        
        unsolvedNodeCount = solver.unsolvedCount()
        undoButtonEnabled = true
        saveSetting()   //  TODO:  find a cleaner solution
        
        if solver.puzzleState == .initial {
            solver.puzzleState = .solving
        }
    }
    
    func undoAction() {
        undoButtonEnabled = false
        solver.dataSet = solver.previousDataSet
        solver.puzzleState = previousState  //  will have effect if last operation was Prune
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
        solver.puzzleState = .initial
        solver.puzzleName = " "
        undoButtonEnabled = false
        let request = URLRequest(url: HLSolver.websudokuURL)
        hlWebView.load(request)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("HLSolverViewController-  webView-  didFinish")
        webView.evaluateJavaScript("document.documentElement.innerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
        //        print( "innerHTML: \(String(describing: html))" )
            
                if let puzzleString = html as? String   {
                    self.solver = HLSolver(html: puzzleString)
                    self.unsolvedNodeCount = self.solver.unsolvedCount()
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
