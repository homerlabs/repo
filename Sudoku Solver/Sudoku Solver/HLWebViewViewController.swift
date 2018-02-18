//
//  HLWebViewViewController.swift
//  Sudoku Solver
//
//  Created by Matthew Homer on 7/13/15.
//  Copyright (c) 2015 Homer Labs. All rights reserved.
//

import UIKit
import WebKit


class HLWebViewViewController: UIViewController, WKNavigationDelegate {

    let urlString = "https://nine.websudoku.com/?"
    var puzzleTitle: String
    var puzzleData: Array<String>
    let viewTall: CGFloat = 248
    let viewShort: CGFloat  = 123
    
    @IBOutlet weak var gotoButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    var webView: WKWebView?
    
    @IBAction func unwindToWebView(_ sender: UIStoryboardSegue)
    {
        let sourceViewController = sender.source
        print("HLWebViewController-  webViewDidFinishLoad: \(sourceViewController)")
    }
    
    
    @IBAction func aboutAction(_ sender: UIButton)
    {
        print("HLWebViewController-  aboutAction")
        self.performSegue( withIdentifier: "GotoAbout", sender:self)
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print( "didFinishNavigationdidFinishNavigation" )
        
        webView.evaluateJavaScript("document.documentElement.innerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
        //        print( "innerHTML: \(String(describing: html))" )
            
                if let puzzleString = html as? String   {
                    self.puzzleData = self.parsePuzzle(data: puzzleString)
       //             print( "puzzleArray: \(self.puzzleData)" )
                }
        })
    }

    
    func parsePuzzle(data: String) -> [String]  {
        var puzzleString = data
        var puzzleArray = Array(repeating: "0", count: 81)

        if let range: Range<String.Index> = puzzleString.range(of:"<form")  {
            puzzleString = String(puzzleString[range.lowerBound...])
    //        print( "*******************puzzleString: \(puzzleString)" )
            
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
            
  //          print( "puzzleString: \(puzzleString)" )
            if let range: Range<String.Index> = puzzleString.range(of:"Copy link for this puzzle\">")  {
                puzzleString = String(puzzleString[range.upperBound..<puzzleString.endIndex])
                if let range2: Range<String.Index> = puzzleString.range(of:"</a>")  {

                    puzzleTitle = String(puzzleString[puzzleString.startIndex..<range2.lowerBound])
                }
           }
        }
        
        return puzzleArray
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any!)
    {
        if segue.identifier == "GotoSolver"
        {
            if let viewController: HLSolverViewController = segue.destination as? HLSolverViewController
            {
                viewController.importArray = puzzleData
                viewController.puzzleName = puzzleTitle
            }
        }
        else if segue.identifier == "GotoAbout"
        {
            print("HLWebViewController-  prepareForSegue-  GotoAbout")
        }
    }


    required init?(coder: NSCoder) {
        puzzleTitle = ""
        puzzleData = Array<String>()
        super.init(coder: coder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
//        print("HLWebViewController-  viewDidLoad")

        let url: URL = URL(string: urlString)!
        let request = URLRequest(url: url)
        webView = WKWebView(frame:containerView.bounds)
        containerView.addSubview(webView!)
        webView!.navigationDelegate = self
        webView!.load(request)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        webView!.stopLoading()
    }
}
