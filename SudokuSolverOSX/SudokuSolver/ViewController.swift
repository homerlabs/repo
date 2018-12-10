//
//  ViewController.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 2/15/18.
//  Copyright © 2018 Matthew Homer. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController, WKNavigationDelegate {

    var webView: WKWebView!
//    var puzzleArray = Array(repeating: 0, count: 81)
    var puzzle = HLSolver()
    var stupidButton = NSButton(frame: NSZeroRect)
    @IBOutlet weak var collectionView: NSCollectionView!

    @IBAction func newPuzzleAction(_ sender: NSButton)  {
        let urlString = "https://nine.websudoku.com/?"
        webView = WKWebView(frame: view.frame)
        webView.navigationDelegate = self

        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url));
        }
    }
    
  fileprivate func configureCollectionView() {
    // 1
    let flowLayout = NSCollectionViewFlowLayout()
    flowLayout.itemSize = NSSize(width: 52.0, height: 52.0)
    flowLayout.sectionInset = NSEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    flowLayout.minimumInteritemSpacing = 1.0
    flowLayout.minimumLineSpacing = 1.0
    collectionView.collectionViewLayout = flowLayout
    // 2
    view.wantsLayer = true
    // 3
    collectionView.layer?.backgroundColor = NSColor.black.cgColor
  }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print( "didFinishNavigationdidFinishNavigation" )
        
        webView.evaluateJavaScript("document.documentElement.innerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
           //     print( "innerHTML: \(String(describing: html))" )
                
                if let puzzleString = html as? String   {
                    self.puzzle = HLSolver(html: puzzleString)
                    self.collectionView.reloadData()
                }
        })
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        print( "ViewController-  viewDidDisappear" )
        exit(0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newPuzzleAction(stupidButton)
        configureCollectionView()
    }
}

extension ViewController : NSCollectionViewDataSource {
  
  func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    return puzzle.kCellCount
  }
  
  func collectionView(_ itemForRepresentedObjectAtcollectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    
    let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HLCollectionViewItem"), for: indexPath)
    guard let collectionViewItem = item as? HLCollectionViewItem else {return item}
    
    let (data, status) = puzzle.dataSet[indexPath.item]
    collectionViewItem.hlTextField.stringValue = puzzle.setToString(data)
       switch status {
        
            case .givenStatus:
                collectionViewItem.hlTextField!.textColor = NSColor.brown
        
            case .solvedStatus:
                collectionViewItem.hlTextField!.textColor = NSColor.green
        
            case .changedStatus:
                collectionViewItem.hlTextField!.textColor = NSColor.red
        
            case .unsolvedStatus:
                collectionViewItem.hlTextField!.textColor = NSColor.blue
        }
    return item
  }
}

