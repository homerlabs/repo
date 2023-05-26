//
//  PuzzleFactory.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 11/26/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import Foundation
import WebKit

public protocol PuzzleFactoryProtocol {
    func puzzleReady(puzzle: HLSolver?)
}


public class PuzzleFactory: NSObject, WKNavigationDelegate {
    static let test_data = "test_data"
    let offlineManager = HLOfflineManager()

    let websudokuURL = URL(string: "https://nine.websudoku.com/?level=4")!
//    let websudokuURL = URL(string: "https://nine.websudoku.com/?level=4&set_id=8543506682")!

    var hlWebView = WKWebView()
    var delegate: PuzzleFactoryProtocol?
    
    //  get random puzzle
    public func getNewPuzzle(isOffline: Bool) {
        getNewPuzzle(isOffline: isOffline, puzzleId: "")
    }

    //  get specific puzzle 
    public func getNewPuzzle(isOffline: Bool, puzzleId: String) {
        
        if isOffline {
            
        }
        else {
            var url = websudokuURL
            
            //  special case where loadRequest is not needed, so we can call puzzleReady() right away
            if puzzleId == PuzzleFactory.test_data {
                var testPuzzle = HLSolver()
                testPuzzle.puzzleName = "TestData--1->81"
                for index in 0..<81 {
                    var cell = testPuzzle.dataSet[index]
                    cell = HLSudokuCell(data: Set(arrayLiteral: String(index+1+100000000)), status: .givenStatus)
                    testPuzzle.dataSet[index] = cell
                }
                self.delegate?.puzzleReady(puzzle: testPuzzle)
                
                //  remember-  no loadRequest
                return
            }
            
            if puzzleId.count > 0 {
                let urlWithIdString = String(format: "https://nine.websudoku.com/?level=4&set_id=\(puzzleId)")
                if let urlWithId = URL(string: urlWithIdString) {
                    url = urlWithId
                }
            }
            print("PuzzleFactory-  getNewPuzzle")
            let request = URLRequest(url: url)
            hlWebView.load(request)
        }
    }
    
    //  must be declared public because of WKNavigation
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("PuzzleFactory-  webView-  didFinish")
        webView.evaluateJavaScript("document.documentElement.innerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
        //        print( "innerHTML: \(String(describing: html))" )
            
            if let puzzleString = html as? String   {
                let solver = self.parseHTMLString(html: puzzleString)
            //     let solver = self.replacePuzzleWithTestData()
                self.delegate?.puzzleReady(puzzle: solver)
            }
        })
    }
    
    func parseHTMLString(html: String) -> HLSolver? {

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
            //  at this point, have parsed all 81 cells, now get puzzleName
            if let range: Range<String.Index> = puzzleString.range(of:"Copy link for this puzzle\">")  {
                puzzleString = String(puzzleString[range.upperBound..<puzzleString.endIndex])
                if let range2: Range<String.Index> = puzzleString.range(of:"</a>")  {
                    
                    let puzzleName = String(puzzleString[puzzleString.startIndex..<range2.lowerBound])
                    offlineManager.insertPuzzle(data: puzzleArray, name: puzzleName)
                    
                    let dataSet = HLSolver.loadWithIntegerArray(puzzleArray)
                    solver = HLSolver(dataSet, puzzleName: puzzleName, puzzleState: .initial)
                }
           }
        }
        
        return solver
    }
    
    public override init() {
        super.init()
        hlWebView = WKWebView(frame:CGRect(x: 0, y: 0, width: 1000, height: 1000))
        hlWebView.navigationDelegate = self
    }
}
