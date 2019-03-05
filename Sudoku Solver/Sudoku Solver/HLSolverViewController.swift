//
//  HLSolverViewController.swift
//  Sudoku Solver
//
//  Created by Matthew Homer on 7/13/15.
//  Copyright (c) 2015 Homer Labs. All rights reserved.
//

import UIKit
import WebKit


class HLSolverViewController: UIViewController, UICollectionViewDataSource, WKNavigationDelegate {

//    var importArray: [String] = Array()
//    var puzzleName = ""

    var _solver = HLSolver()
    var nodeCount = 0
    
    var rowsSelected    = true
    var columnsSelected = true
    var blocksSelected  = true
    var savedBlocksSelected  = true //  needed for when button is disabled

    let defaults = UserDefaults.standard
    let rowSwitchKey    = "Row"
    let columnSwitchKey = "Column"
    let blockSwitchKey  = "Block"
    let modeSelectKey   = "mode"
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var puzzleNameLabel: UILabel!
    @IBOutlet weak var nodeCountLabel: UILabel!
    @IBOutlet weak var algorithmSelect: UISegmentedControl!
    
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var solveButton: UIButton!
    @IBOutlet weak var readButton: UIButton!
    @IBOutlet weak var writeButton: UIButton!

    @IBOutlet weak var rowSwitch: UISwitch!
    @IBOutlet weak var columnSwitch: UISwitch!
    @IBOutlet weak var blockSwitch: UISwitch!
    
    var puzzleTitle = ""
    var hlWebView = WKWebView()


    @IBAction func newPuzzleAction(_ sender: UIButton)
    {
        print("HLSolverViewController-  newPuzzleAction")
        solveButton.setTitle("Prune", for: .normal)
        _solver = HLSolver()
        updateDisplay()
        
        let request = URLRequest(url: _solver.url)
        hlWebView = WKWebView(frame:self.view.bounds)
        hlWebView.navigationDelegate = self
        hlWebView.load(request)
        solveButton.isEnabled = false
   }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("HLSolverViewController-  webView-  didFinish")
        webView.evaluateJavaScript("document.documentElement.innerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
        //        print( "innerHTML: \(String(describing: html))" )
            
                if let puzzleString = html as? String   {
                    self._solver = HLSolver(html: puzzleString)
        //           print( "puzzleString: \(puzzleString)" )
                    self.updateDisplay()
                    self.undoButton.isEnabled = false
                    self.solveButton.isEnabled = true
                }
        })
    }
    
    
    func updateDisplay()    {
        puzzleNameLabel.text = _solver.puzzleName
        updateAndDisplayCells()
    }

    
    @IBAction func undoAction(_ sender:UISwitch)
    {
        print( "HLSolverViewController-  undoAction" )
        _solver.dataSet = _solver.previousDataSet
        updateAndDisplayCells()
        
        undoButton.isEnabled = false
    }
    
    
    @IBAction func readAction()
    {
        _solver.read()
        puzzleNameLabel.text = _solver.puzzleName
 //       _solver.prunePuzzle(rows:true, columns:true, blocks:true)
        updateAndDisplayCells()
    }
    
    
    @IBAction func writeAction()
    {
        _solver.save()
    }

    
    @IBAction func settingsAction()
    {
        rowsSelected    = rowSwitch.isOn
        columnsSelected = columnSwitch.isOn
        blocksSelected  = blockSwitch.isOn
        savedBlocksSelected  = blockSwitch.isOn

        defaults.set(!rowsSelected,     forKey:rowSwitchKey )
        defaults.set(!columnsSelected,  forKey:columnSwitchKey )
        defaults.set(!blocksSelected,   forKey:blockSwitchKey )
    }
    
    
    @IBAction func modeSelectAction()
    {
        defaults.set(algorithmSelect.selectedSegmentIndex, forKey: modeSelectKey)

        //  disable Blocks Switch for Mono Cell Mode
        if algorithmSelect.selectedSegmentIndex == HLAlgorithmMode.MonoCell.rawValue        {
            blockSwitch.isEnabled = false
            blockSwitch.isOn = false
        }
        
        else if algorithmSelect.selectedSegmentIndex == HLAlgorithmMode.FindSets.rawValue    {
            blockSwitch.isEnabled = true
            blockSwitch.isOn = savedBlocksSelected
        }
        
        //  disable Blocks Switch for Mono Sector Mode
        else if algorithmSelect.selectedSegmentIndex == HLAlgorithmMode.MonoSector.rawValue    {
            blockSwitch.isEnabled = false
            blockSwitch.isOn = false
        }
    }
    
    
    @IBAction func solveAction(_ sender:UIButton)
    {
        _solver.previousDataSet = _solver.dataSet

        if _solver.puzzleState == .Initial   {
            _solver.puzzleState = .Solving
            solveButton.setTitle("Solve", for: .normal)
            _solver.prunePuzzle(rows:true, columns:true, blocks:true)
            _solver.previousDataSet = _solver.dataSet  //  remove 'Changed' status from cells
        }
        else    {
           switch( algorithmSelect.selectedSegmentIndex )
            {
                case HLAlgorithmMode.MonoCell.rawValue:
                    _solver.findMonoCells(rows: rowsSelected, columns: columnsSelected)
                    break
            
                case HLAlgorithmMode.FindSets.rawValue:
                    _solver.findPuzzleSets(rows: rowsSelected, columns: columnsSelected, blocks: blocksSelected)
                    break
            
                case HLAlgorithmMode.MonoSector.rawValue:
                    _solver.findMonoSectors(rows: rowsSelected, columns: columnsSelected)
                    break
            
                default:
                    break
            }
        
            undoButton.isEnabled = true
        }
        
        updateAndDisplayCells()
    }
    
    
    func updateAndDisplayCells()    {
        _solver.updateChangedCells()
        collectionView.reloadData()
        let unsolvedCount = _solver.unsolvedCount()
        nodeCountLabel.text = "Unsolved Nodes: \(unsolvedCount)"
        
        if unsolvedCount == 0   {   solveButton.isEnabled = false    }
        else                    {   solveButton.isEnabled = true     }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int)->Int
    {
        return _solver.kCellCount
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath)->UICollectionViewCell
    {

        let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HLPuzzleCell",
                                        for: indexPath) as! HLCollectionViewCell
        
        let (setData, status) = _solver.dataSet[indexPath.row]

        cell.hlLabel!.text = _solver.setToString(setData)

       switch status {
            
            case .givenStatus:
                cell.hlLabel!.textColor = UIColor.brown
        
            case .solvedStatus:
                cell.hlLabel!.textColor = UIColor.green
        
            case .changedStatus:
                cell.hlLabel!.textColor = UIColor.red
        
            case .unsolvedStatus:
                cell.hlLabel!.textColor = UIColor.blue
        }

        return cell
    }


    override func viewDidLoad()     {
        super.viewDidLoad()

        let nib = UINib(nibName:"HLCollectionViewCell", bundle:nil)
        collectionView.register(nib, forCellWithReuseIdentifier:"HLPuzzleCell")
        
        algorithmSelect.selectedSegmentIndex = defaults.integer(forKey: modeSelectKey)
        rowsSelected        = !defaults.bool(forKey: rowSwitchKey)
        columnsSelected     = !defaults.bool(forKey: columnSwitchKey)
        blocksSelected      = !defaults.bool(forKey: blockSwitchKey)
        rowSwitch.isOn       = rowsSelected
        columnSwitch.isOn    = columnsSelected
        blockSwitch.isOn     = blocksSelected
        
        undoButton.isEnabled = false
        
        let findSetsSelected = (algorithmSelect.selectedSegmentIndex == HLAlgorithmMode.FindSets.rawValue)
        if !findSetsSelected {
            blockSwitch.isEnabled  = false
            blockSwitch.isOn  = false
        }
        blockSwitch.isEnabled = (algorithmSelect.selectedSegmentIndex == HLAlgorithmMode.FindSets.rawValue)

//        _solver.read()
//        updateAndDisplayCells()
//        _solver.findSetsForRow(0, sizeOfSet: 3)
//        updateAndDisplayCells()

  //      _solver.load(importArray)
  //      _solver.prunePuzzle(rows:true, columns:true, blocks:true)
  //      nodeCountLabel.text = "Unsolved Nodes: \(_solver.unsolvedCount())"
        
        newPuzzleAction(undoButton)
        
 //       #if !HLDEBUG
            readButton.isHidden = true
            writeButton.isHidden = true
 //       #endif
    }
}
