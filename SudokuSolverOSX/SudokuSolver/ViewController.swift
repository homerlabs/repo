//
//  ViewController.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 2/15/18.
//  Copyright © 2018 Matthew Homer. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController {

    var webView: WKWebView!
    var puzzleArray = Array(repeating: 0, count: 81)
    var puzzle = HLSolver()
    var stupidButton = NSButton(frame: NSZeroRect)
    @IBOutlet weak var collectionView: NSCollectionView!

    @IBAction func newPuzzleAction(_ sender: NSButton)  {
        let urlString = "https://nine.websudoku.com/?"
        webView = WKWebView(frame: view.frame)

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

    func parsePuzzle(data: String)  {
        var puzzleString = data

        if let range: Range<String.Index> = puzzleString.range(of:"<form")  {
            puzzleString = String(puzzleString[range.lowerBound...])
    //        print( "*******************puzzleString: \(puzzleString)" )
            
            for index in 0..<81 {
                if let range: Range<String.Index> = puzzleString.range(of:"</td>")  {
                    let preString = puzzleString[puzzleString.startIndex...range.upperBound]
       //             print( "*******************preString: \(preString)" )
                    puzzleString.removeFirst(preString.count)
                    
                    if let range: Range<String.Index> = preString.range(of:"value=\"")  {
                        if let value = Int(String(preString[range.upperBound])) {
               //             print( "valueString: \(value)" )
                            puzzleArray[index] = value
                        }
                    }
                }
            }
            
     //       print( "puzzleString: \(puzzleString)" )
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print( "didFinishNavigationdidFinishNavigation" )
        
        webView.evaluateJavaScript("document.documentElement.innerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
           //     print( "innerHTML: \(String(describing: html))" )
                
                if let puzzleString = html as? String   {
                    self.parsePuzzle(data: puzzleString)
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
        for index in 0..<puzzleArray.count   {
            puzzleArray[index] = index
        }
    }
}

extension ViewController : NSCollectionViewDataSource {
  
  // 2
  func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        print( "puzzleArray.count: \(puzzleArray.count)" )
    return puzzleArray.count
  }
  
  // 3
  func collectionView(_ itemForRepresentedObjectAtcollectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    
    // 4
    let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HLCollectionViewItem"), for: indexPath)
    guard let collectionViewItem = item as? HLCollectionViewItem else {return item}
    
    // 5
        let item2 = puzzleArray[indexPath.item]
    collectionViewItem.hlTextField.stringValue = String(item2)
    return item
  }
}

