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

    let urlString = "https://nine.websudoku.com/?level=4&amp;"
    var puzzleTitle: String
    var puzzleData: Array<String>
    
    @IBOutlet weak var containerView: UIView!
    var hlWebView: WKWebView!
    
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
        
        webView.evaluateJavaScript("document.documentElement.innerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
        //        print( "innerHTML: \(String(describing: html))" )
            
                if let puzzleString = html as? String   {
                    let success = self.parsePuzzle(data: puzzleString)
      //              print( "puzzleString: \(puzzleString)" )
                    print( "parsePuzzle success: \(success)" )
                }
        })
    }

    
    //  returns true if successful
    //  if parse if good, set puzzleData and puzzleTitle
    func parsePuzzle(data: String) -> Bool  {
        var puzzleString = data
        var puzzleArray = Array(repeating: "0", count: 81)

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
            
  //          print( "puzzleString: \(puzzleString)" )
            if let range: Range<String.Index> = puzzleString.range(of:"Copy link for this puzzle\">")  {
                puzzleString = String(puzzleString[range.upperBound..<puzzleString.endIndex])
                if let range2: Range<String.Index> = puzzleString.range(of:"</a>")  {
                    puzzleTitle = String(puzzleString[puzzleString.startIndex..<range2.lowerBound])
                    puzzleData = puzzleArray
                    print( "*******************puzzleTitle: \(puzzleTitle)" )
                    return true
                }
           }
        }
        
        return false    //  parse failed
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
/*        else if segue.identifier == "GotoAbout"
        {
            if let viewController: HLHelpViewController = segue.destination as? HLHelpViewController
            {
                viewController.pdf = "Hi!"
            }
        }   */
    }


    required init?(coder: NSCoder) {
        puzzleTitle = ""
        puzzleData = Array<String>()
        super.init(coder: coder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
//        print("HLWebViewController-  viewDidLoad")

    }
    
/*    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        print("HLWebViewController-  viewWillAppear")
        let url: URL = URL(string: urlString)!
        let request = URLRequest(url: url)
        hlWebView = WKWebView(frame:containerView.bounds)
        containerView.addSubview(hlWebView)
        hlWebView.navigationDelegate = self
        hlWebView.load(request)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        hlWebView.stopLoading()
    }   */
}
