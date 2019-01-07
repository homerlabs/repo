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
    let filepathManager = HLFilePathManager()

    @IBOutlet weak var algorithmSelect: NSSegmentedControl!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var puzzleNameTextField: NSTextField!
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
 //       print( "modeSelectAction" )
        defaults.set(algorithmSelect.selectedSegment, forKey: modeSelectKey)

        //  disable Blocks Switch for Mono Cell Mode
        if algorithmSelect.selectedSegment == HLAlgorithmMode.MonoCellAlgorithm.rawValue       {       //  Mono Cell
            blockSwitch.isEnabled = false
            savedBlocksSelected = blockSwitch.state
            blockSwitch.state = .off
        }
        
        else if algorithmSelect.selectedSegment == HLAlgorithmMode.FindSetsAlgorithm.rawValue    {      //  Find Sets
            blockSwitch.isEnabled = true
            blockSwitch.state = savedBlocksSelected
        }
        
        //  disable Blocks Switch for Mono Sector Mode
        else if algorithmSelect.selectedSegment == HLAlgorithmMode.MonoSectorAlgorithm.rawValue    {      //  Mono Sector
            blockSwitch.isEnabled = false
            savedBlocksSelected = blockSwitch.state
            blockSwitch.state = .off
        }
    }


   @IBAction func openAction(_ sender: Any)  {
        if let path = filepathManager.getOpenFilePath(title: "Open Sudoku Data File", bookmarkKey: "not used")    {
            let url = URL(fileURLWithPath: path)
            print( "openAction: \(String(describing: path))" )
            var inString = ""
            do {
                inString = try String(contentsOf: url)
                puzzle.loadPuzzleWith(data: inString)
                
                let unsolvedCount = puzzle.unsolvedCount()
                nodeCountTextField.stringValue = "Unsolved Nodes: \(unsolvedCount)"
                solveButton.isEnabled = (unsolvedCount != 0)
                collectionView.reloadData()
                puzzleNameTextField.stringValue = puzzle.puzzleName
            } catch {
                print("Failed reading from URL: \(url), Error: " + error.localizedDescription)
            }
     //       print("Read from the file: \(inString)")
        }
    }
    
   @IBAction func saveAction(_ sender: Any)  {
        if let path = filepathManager.getSaveFilePath(title: "Sudoku Solver Save Panel", fileName: "SudokuData", bookmarkKey: "not used")    {
            let url = URL(fileURLWithPath: path)
            print( "saveAction: path" )
            let outString = puzzle.dataToString()
            do {
                try outString.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                print("Failed writing to URL: \(url), Error: " + error.localizedDescription)
            }
        }
    }
    
   @IBAction func newPuzzleAction(_ sender: Any)  {
        fetchPuzzle(url: puzzle.url)
    }
    
    @IBAction func fetchPuzzleAction(_ sender: Any) {
//        print( "fetchPuzzleAction" )
        
        let alert = NSAlert()
        alert.messageText = "Enter the puzzle id:"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 170, height: 20))
        alert.accessoryView = textField
        
        let buttonPressed = alert.runModal()
        
        if buttonPressed == NSApplication.ModalResponse.alertFirstButtonReturn {
            if let url = URL(string: "\(puzzle.url.absoluteString)&set_id=\(textField.stringValue)")    {  fetchPuzzle(url: url)            }
            else                                                                                        {   fetchPuzzle(url: puzzle.url)    }
        }
    }
    
    func fetchPuzzle(url: URL)   {
//        print( "fetchPuzzle: \(url)" )
        webView = WKWebView(frame: view.frame)
        webView.navigationDelegate = self
        webView.load(URLRequest(url: url));
    
        undoButton.isEnabled = false
        solveButton.isEnabled = false
        puzzleNameTextField.stringValue = ""
    }

    @objc func printQuote(_ sender: Any?) {
        let quoteText = "Never put off until tomorrow what you can do the day after tomorrow."
        let quoteAuthor = "Mark Twain"

        print("\(quoteText) — \(quoteAuthor)")
    }

  fileprivate func configureCollectionView() {
    let flowLayout = NSCollectionViewFlowLayout()
    flowLayout.itemSize = NSSize(width: 52.0, height: 54.0)
    flowLayout.sectionInset = NSEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    flowLayout.minimumInteritemSpacing = 1.0
    flowLayout.minimumLineSpacing = 1.0
    collectionView.collectionViewLayout = flowLayout
    view.wantsLayer = true
    collectionView.layer?.backgroundColor = NSColor.black.cgColor
  }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print( "WKNavigationDelegate-  didFinish" )
        
        webView.evaluateJavaScript("document.documentElement.innerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
       //         print( "innerHTML: \(String(describing: html))" )
                
                if let puzzleString = html as? String   {
                    self.puzzle = HLSolver(html: puzzleString)
                    self.puzzleNameTextField.stringValue = self.puzzle.puzzleName
                    self.updateDisplay()
                }
        })
    }
    
    func updateDisplay()  {
        let unsolvedCount = puzzle.unsolvedCount()
        nodeCountTextField.stringValue = "Unsolved Nodes: \(unsolvedCount)"
        solveButton.isEnabled = (unsolvedCount != 0)
        puzzle.updateChangedCells() //  make sure to call this befoe reloading collectionview
        collectionView.reloadData()
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
        
        let findSetsSelected = (algorithmSelect.selectedSegment == HLAlgorithmMode.FindSetsAlgorithm.rawValue)
        if !findSetsSelected {
            blockSwitch.isEnabled  = false
            blockSwitch.state  = .off
        }
        blockSwitch.isEnabled = (algorithmSelect.selectedSegment == HLAlgorithmMode.FindSetsAlgorithm.rawValue)
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

