//
//  HLWebViewViewController.swift
//  Sudoku Solver
//
//  Created by Matthew Homer on 7/13/15.
//  Copyright (c) 2015 Homer Labs. All rights reserved.
//

import UIKit

class HLWebViewViewController: UIViewController {

    var puzzleTitle: String
    var puzzleData: Array<String>
    let viewTall: CGFloat = 248
    let viewShort: CGFloat  = 123
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint?
    @IBOutlet weak var webView: UIWebView?
    @IBOutlet weak var gotoButton: UIButton?

    
    @IBAction func unwindToWebView(sender: UIStoryboardSegue)
    {
        let sourceViewController = sender.sourceViewController
        print("HLWebViewController-  webViewDidFinishLoad: \(sourceViewController)")
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator)    {
        
        if (size.width > size.height)   {   heightConstraint!.constant = viewShort  }
        else                            {   heightConstraint!.constant = viewTall   }
    }
    
    
    func parseHTML( data: String)
    {
        var count = 0;
        print( "data:\(data)" )
        var stringArray = Array<String>()
        let formTag = data.rangeOfString("<form")
        
        if( formTag != nil )
        {
            var remainingString = data.substringFromIndex(formTag!.endIndex)
            var tdTag = remainingString.rangeOfString("<td ")
            
            while( tdTag != nil && count < 81 )
            {
                remainingString = remainingString.substringFromIndex(tdTag!.endIndex)
                
                if let tdClosingTag = remainingString.rangeOfString("</td>")
                {
                   if let readonlyTag = remainingString.rangeOfString("value=")
                    {
                        if( tdClosingTag.startIndex > readonlyTag.startIndex )
                        {
                            remainingString = remainingString.substringFromIndex(readonlyTag.endIndex.advancedBy(1))
                            
                            let t1 = remainingString.substringToIndex(remainingString.startIndex.advancedBy(1))
                            stringArray.append(t1)
                        }
                        else
                        {
                            stringArray.append("0")
                        }
                    }
                    else    //  this may be needed if the last cell is empty
                    {
                       stringArray.append("0")
                    }
                }
                
                count++
                tdTag = remainingString.rangeOfString("<td")
            }
            
            if ( stringArray.count == 81 )
            {
                puzzleData = stringArray
                
                let nameTag = remainingString.rangeOfString("Copy link for this puzzle")
                remainingString = remainingString.substringFromIndex(nameTag!.endIndex.advancedBy(2))
                let endTag = remainingString.rangeOfString("</a>")
                puzzleTitle = remainingString.substringToIndex(endTag!.startIndex)
                gotoButton?.enabled = true;
    //           print( "puzzleData: \(puzzleData)" )
    //           print( "puzzleTitle: \(puzzleTitle)" )
            }
            else
            {
               print( "Bad, bad parse!" )
                assert( false );
            }
        }
    }


    required init?(coder: NSCoder) {
        puzzleTitle = ""
        puzzleData = Array<String>()
        super.init(coder: coder)
    }


    func webViewDidFinishLoad(webView: UIWebView)
    {
        
        let data = webView.stringByEvaluatingJavaScriptFromString("document.documentElement.outerHTML")
        print("HLWebViewController-  webViewDidFinishLoad")
       
        parseHTML(data!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        print("HLWebViewController-  viewDidLoad")
        
        let url = NSURL(string: "http://view.websudoku.com")
        let request = NSURLRequest(URL: url!)
        webView!.loadRequest(request)
    }


    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)

        if (UIDevice.currentDevice().orientation == .LandscapeLeft || UIDevice.currentDevice().orientation == .LandscapeRight)    {
            heightConstraint!.constant = viewShort
        }
        else {
            heightConstraint!.constant = viewTall
        }
    }
    

    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        webView!.stopLoading()
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        if segue.identifier == "GotoSolver"
        {
            if let viewController: HLSolverViewController = segue.destinationViewController as? HLSolverViewController
            {
                viewController.importArray = puzzleData
                viewController.puzzleName = puzzleTitle
            }
        }
    }
}
