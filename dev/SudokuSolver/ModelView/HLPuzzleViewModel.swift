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
    @Published var testRows = true
    @Published var testColumns = true
    @Published var testBlocks = true
    @Published var undoButtonEnabled = false
    
    var previousState = HLPuzzleState.initial

    let hlKeySettingRow         = "hlKeySettingRow"
    let hlKeySettingColumn      = "hlKeySettingColumn"
    let hlKeySettingBlock       = "hlKeySettingBlock"
    let hlKeySettingAlgorithm   = "hlKeySettingAlgorithm"
        
    var hlWebView = WKWebView()
    
    func solveAction() {
        solver.previousDataSet = solver.dataSet
        previousState = solver.puzzleState  //  needed for the Undo button after initial Prune operation
        
        if solver.puzzleState == .initial {
            if !solver.prunePuzzle(rows: true, columns: true, blocks: true) {
                print("Serious ERROR:  Puzzle data not valid!")
            }
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
        
        undoButtonEnabled = true
        saveSetting()   //  TODO:  find a cleaner solution
        
        if solver.puzzleState == .initial {
            solver.puzzleState = .solving
        }
    }
    
    func fastSolve() {
        while solver.unsolvedNodeCount > 0 {
            print("solver: \(solver)")
            
            solver.findMonoCells(rows: testRows, columns: testBlocks)
            guard solver.unsolvedNodeCount > 0 else { return }
            
            solver.findPuzzleSets(rows: testRows, columns: testColumns, blocks: testBlocks)
            guard solver.unsolvedNodeCount > 0 else { return }
            
            solver.findMonoSectors(rows: testRows, columns: testColumns)
        }
    }
    
    func undoAction() {
        undoButtonEnabled = false
        solver.dataSet = solver.previousDataSet
        solver.puzzleState = previousState  //  will have effect if last operation was Prune
        solver.updateUnsolvedCount()
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
        
        print("HLPuzzleViewModel-  webView-  didFinish")
        webView.evaluateJavaScript("document.documentElement.innerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
        //        print( "innerHTML: \(String(describing: html))" )
            
            if let puzzleString = html as? String   {
                if let solver = HLPuzzleViewModel.parseHTMLString(html: puzzleString) {
                    self.solver = solver
               //     self.solver = self.replacePuzzleWithTestData()
               }
            }
        })
    }
    
    func replacePuzzleWithTestData() -> HLSolver {
        let dataSet = HLSolver.loadWithIntegerArray(HLSolver.testData)
        let solver = HLSolver(dataSet, puzzleName: "TestData", puzzleState: .solving)
        solver.prunePuzzle(rows: true, columns: true, blocks: true)
        return solver
    }

    class func parseHTMLString(html: String) -> HLSolver? {

        //  start of: parseHTMLString()
 //       print("HLPuzzleViewModel-  parseHTMLString(html: String)")
        var puzzleString = html
        var puzzleArray = Array(repeating: 0, count: 81)
        
        var solver: HLSolver?
        
        if let range: Range<String.Index> = puzzleString.range(of:"<form")  {
            puzzleString = String(puzzleString[range.lowerBound...])
  //          print( "*******************puzzleString: \(puzzleString)" )
            
            for index in 0..<81 {
                if let range: Range<String.Index> = puzzleString.range(of:"</td>")  {
                    let preString = puzzleString[puzzleString.startIndex...range.upperBound]
       //             print( "*******************preString: \(preString)" )
                    puzzleString.removeFirst(preString.count)
                    
                    if let range: Range<String.Index> = preString.range(of:"value=\"")  {
                        if let num = Int(String(preString[range.upperBound])) {
                            puzzleArray[index] = num
                        }
                    }
                }
            }
            
    //        print( "puzzleString: \(puzzleString)" )
            if let range: Range<String.Index> = puzzleString.range(of:"Copy link for this puzzle\">")  {
                puzzleString = String(puzzleString[range.upperBound..<puzzleString.endIndex])
                if let range2: Range<String.Index> = puzzleString.range(of:"</a>")  {
                    let puzzleName = String(puzzleString[puzzleString.startIndex..<range2.lowerBound])
                    let dataSet = HLSolver.loadWithIntegerArray(puzzleArray)
                    solver = HLSolver(dataSet, puzzleName: puzzleName, puzzleState: .initial)
                }
           }
        }
        
        return solver
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
