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

    var puzzle = HLSolver()
    var webView: WKWebView!
    var rowsSelected: NSControl.StateValue = .on
    var columnsSelected: NSControl.StateValue = .on
    var blocksSelected: NSControl.StateValue = .on
    var savedBlocksSelected: NSControl.StateValue = .on //  needed for when button is disabled

    @IBOutlet weak var algorithmSelect: NSSegmentedControl!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var nodeCountTextField: NSTextField!
    @IBOutlet weak var solveButton: NSButton!
    @IBOutlet weak var undoButton: NSButton!
    @IBOutlet weak var rowSwitch: NSButton!
    @IBOutlet weak var columnSwitch: NSButton!
    @IBOutlet weak var blockSwitch: NSButton!
    let defaults = UserDefaults.standard
    let rowSwitchKey    = "Row"
    let columnSwitchKey = "Column"
    let blockSwitchKey  = "Block"
    let modeSelectKey   = "mode"
    let archiveKey      = "Archive"

    @IBAction func settingsAction(_ sender: NSButton)
    {
        rowsSelected    = rowSwitch.state
        columnsSelected = columnSwitch.state
        blocksSelected  = blockSwitch.state
        savedBlocksSelected  = blockSwitch.state

  //      let x = (rowsSelected == .off).rawValue
        defaults.set(rowsSelected == .off,     forKey:rowSwitchKey )
        defaults.set(columnsSelected == .off,  forKey:columnSwitchKey )
        defaults.set(blocksSelected == .off,   forKey:blockSwitchKey )
    }

    @IBAction func undoAction(_ sender: NSButton)
    {
        print( "undoAction" )
        puzzle.dataSet = puzzle.previousDataSet
        updateDisplay()
        
        solveButton.isEnabled = true
        undoButton.isEnabled = false
    }

    @IBAction func solveAction(_ sender: NSButton)  {
        puzzle.previousDataSet = puzzle.dataSet
        
        switch( algorithmSelect.selectedSegment )
        {
            case 0:     //  Mono Cell
                puzzle.findMonoCells(rows: rowsSelected == .on, columns: columnsSelected == .on)
                break
        
            case 1:     //  Find Sets
                puzzle.findPuzzleSets(rows: rowsSelected == .on, columns: columnsSelected == .on, blocks: blocksSelected == .on)
                break
        
            case 2:     //  Mono Sectors
                puzzle.findMonoSectors(rows: rowsSelected == .on, columns: columnsSelected == .on)
                break
        
            default:
                break
        }
        
        undoButton.isEnabled = true
        updateDisplay()
    }
    
    @IBAction func modeSelectAction(_ sender:NSSegmentedControl)    {
        print( "modeSelectAction" )
        defaults.set(algorithmSelect.selectedSegment, forKey: modeSelectKey)

        //  disable Blocks Switch for Mono Cell Mode
        if algorithmSelect.selectedSegment == 0        {       //  Mono Cell
            blockSwitch.isEnabled = false
            savedBlocksSelected = blockSwitch.state
            blockSwitch.state = .off
        }
        
        else if algorithmSelect.selectedSegment == 1    {      //  Find Sets
            blockSwitch.isEnabled = true
            blockSwitch.state = savedBlocksSelected
        }
        
        //  disable Blocks Switch for Mono Sector Mode
        else if algorithmSelect.selectedSegment == 2    {      //  Mono Sector
            blockSwitch.isEnabled = false
            savedBlocksSelected = blockSwitch.state
            blockSwitch.state = .off
        }
    }


   @IBAction func newPuzzleAction(_ sender: NSButton)  {
        let urlString = "https://nine.websudoku.com/?"
        webView = WKWebView(frame: view.frame)
        webView.navigationDelegate = self

        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url));
        }
    
        undoButton.isEnabled = false
        solveButton.isEnabled = true
    }
    
  fileprivate func configureCollectionView() {
    // 1
    let flowLayout = NSCollectionViewFlowLayout()
    flowLayout.itemSize = NSSize(width: 52.0, height: 54.0)
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
                    self.updateDisplay()
                }
        })
    }
    
    func updateDisplay()  {
        collectionView.reloadData()
        let unsolvedCount = puzzle.unsolvedCount()
        nodeCountTextField.stringValue = "Unsolved Nodes: \(unsolvedCount)"
        
        if unsolvedCount == 0 {
            solveButton.isEnabled = false
}
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        print( "ViewController-  viewDidDisappear" )
        exit(0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        algorithmSelect.selectedSegment = defaults.integer(forKey: modeSelectKey)
        rowsSelected        = NSControl.StateValue.init(rawValue: Int(!defaults.bool(forKey: rowSwitchKey)))
        columnsSelected     = NSControl.StateValue.init(rawValue: Int(!defaults.bool(forKey: columnSwitchKey)))
        blocksSelected      = NSControl.StateValue.init(rawValue: Int(!defaults.bool(forKey: blockSwitchKey)))
        rowSwitch.state     = rowsSelected
        columnSwitch.state  = columnsSelected
        blockSwitch.state   = blocksSelected
        configureCollectionView()
        
        newPuzzleAction(undoButton)    //  passed in value not used
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

