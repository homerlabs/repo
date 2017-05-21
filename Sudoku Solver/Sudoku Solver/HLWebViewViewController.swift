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

    var puzzleTitle: String
    var puzzleData: Array<String>
    let viewTall: CGFloat = 248
    let viewShort: CGFloat  = 123
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint?
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
        print("HLWebViewController-  didFinishNavigation: \(navigation)")

        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
                           completionHandler: { (html: AnyObject?, error: NSError?) in
        //    print(html)
            self.parseHTML(html as! String)
            } as? (Any?, Error?) -> Void)
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)    {
        
        if (size.width > size.height)   {   heightConstraint!.constant = viewShort  }
        else                            {   heightConstraint!.constant = viewTall   }
    }
    
    
    func parseHTML( _ data: String)
    {
        var count = 0;
//        print( "data:\(data)" )
        var stringArray = Array<String>()
        let formTag = data.range(of: "<form")
        
        if( formTag != nil )
        {
            var remainingString = data.substring(from: formTag!.upperBound)
            var tdTag = remainingString.range(of: "<td ")
            
            while( tdTag != nil && count < 81 )
            {
                remainingString = remainingString.substring(from: tdTag!.upperBound)
                
                if let tdClosingTag = remainingString.range(of: "</td>")
                {
                   if let readonlyTag = remainingString.range(of: "value=")
                    {
                        if( tdClosingTag.lowerBound > readonlyTag.lowerBound )
                        {
 //                           remainingString = remainingString.substring(from: <#T##String.CharacterView corresponding to your index##String.CharacterView#>.index(readonlyTag.upperBound, offsetBy: 1))
                            
                            let t1 = remainingString.substring(to: remainingString.characters.index(remainingString.startIndex, offsetBy: 1))
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
                
                count += 1
                tdTag = remainingString.range(of: "<td")
            }
            
            if ( stringArray.count == 81 )
            {
                puzzleData = stringArray
                
                let nameTag = remainingString.range(of: "Copy link for this puzzle")
                
                remainingString = remainingString.substring(from: nameTag!.upperBound)
                let newIndex = remainingString.index(after: remainingString.startIndex)
                let newIndex2 = remainingString.index(after: newIndex)
                remainingString = remainingString.substring(from: newIndex2)
                
                let endTag = remainingString.range(of: "</a>")
                puzzleTitle = remainingString.substring(to: endTag!.lowerBound)
                gotoButton.isEnabled = true;
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

        let url: URL = URL(string: "http://view.websudoku.com")!
        let request = URLRequest(url: url)
        webView = WKWebView(frame:containerView.bounds)
        containerView.addSubview(webView!)
        webView!.navigationDelegate = self
        webView!.load(request)
    }
    
    
/*    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)


        if (UIDevice.currentDevice().orientation == .LandscapeLeft || UIDevice.currentDevice().orientation == .LandscapeRight)    {
            heightConstraint!.constant = viewShort
        }
        else {
            heightConstraint!.constant = viewTall
        }
    }   */
    

    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        webView!.stopLoading()
    }
}
