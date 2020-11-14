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
    let hlKeyPuzzleData         = "hlKeyPuzzleData"
        
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
    
    func saveData(_ dataSet: [HLSudokuCell]) {
        print( "HLPuzzleViewModel-  saveData" )
        let solver = HLSolver(dataSet, puzzleName: self.solver.puzzleName)
        let plistEncoder = PropertyListEncoder()
        if let data = try? plistEncoder.encode(solver) {
            UserDefaults.standard.set(data, forKey: hlKeyPuzzleData)
        }
    }

    func loadData()  {
            print( "HLPuzzleViewModel-  loadData" )
            
        if let data = UserDefaults.standard.data(forKey: hlKeyPuzzleData)    {
            let plistDecoder = PropertyListDecoder()
            if let solver  = try? plistDecoder.decode(HLSolver.self, from:data) {
                self.solver = solver
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("HLPuzzleViewModel-  webView-  didFinish")
        webView.evaluateJavaScript("document.documentElement.innerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
        //        print( "innerHTML: \(String(describing: html))" )
            
                if let puzzleString = html as? String   {
                    self.solver = HLPuzzleViewModel.parseHTMLString(html: puzzleString)
                    self.unsolvedNodeCount = self.solver.unsolvedCount()
                }
        })
    }

    class func parseHTMLString(html: String) -> HLSolver {

        func load(_ data: [String]) -> [HLSudokuCell]
        {
            var dataSet: [HLSudokuCell] = []

            if data.count == HLSolver.kCellCount     {
                for item in data
                {
                    let cellValue = item
                    var newCell = HLSudokuCell(data: HLSolver.fullSet, status: .unsolvedStatus)
                    
                    if ( cellValue != "0" )     {
                        newCell = HLSudokuCell(data: Set([cellValue]), status: .givenStatus)
                    }
                    
                    dataSet.append(newCell)
                }
            }
            
            return dataSet
        }

        //  start of: parseHTMLString()
        print("HLPuzzleViewModel-  parseHTMLString(html: String)")
        var puzzleString = html
        var puzzleArray = Array(repeating: "0", count: 81)
        
        var solver = HLSolver()
        
        if let range: Range<String.Index> = puzzleString.range(of:"<form")  {
            puzzleString = String(puzzleString[range.lowerBound...])
  //          print( "*******************puzzleString: \(puzzleString)" )
            
            for index in 0..<81 {
                if let range: Range<String.Index> = puzzleString.range(of:"</td>")  {
                    let preString = puzzleString[puzzleString.startIndex...range.upperBound]
       //             print( "*******************preString: \(preString)" )
                    puzzleString.removeFirst(preString.count)
                    
                    if let range: Range<String.Index> = preString.range(of:"value=\"")  {
                        puzzleArray[index] = String(preString[range.upperBound])
                    }
                }
            }
            
    //        print( "puzzleString: \(puzzleString)" )
            if let range: Range<String.Index> = puzzleString.range(of:"Copy link for this puzzle\">")  {
                puzzleString = String(puzzleString[range.upperBound..<puzzleString.endIndex])
                if let range2: Range<String.Index> = puzzleString.range(of:"</a>")  {
                    let puzzleName = String(puzzleString[puzzleString.startIndex..<range2.lowerBound])
                    let dataSet = load(puzzleArray)
                    solver = HLSolver(dataSet, puzzleName: puzzleName)
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
