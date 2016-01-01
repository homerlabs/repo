//
//  HLSolverViewController.swift
//  Sudoku Solver
//
//  Created by Matthew Homer on 7/13/15.
//  Copyright (c) 2015 Homer Labs. All rights reserved.
//

import UIKit

class HLSolverViewController: UIViewController, UICollectionViewDataSource {

    var importArray: [String] = Array()
    var puzzleName = ""

    var _solver = HLSolver()
    var nodeCount = 0
    
    var rowsSelected    = true
    var columnsSelected = true
    var blocksSelected  = true
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let rowSwitchKey    = "Row"
    let columnSwitchKey = "Column"
    let blockSwitchKey  = "Block"
    let moodeSelectKey  = "mode"
    let archiveKey      = "Archive"
    
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var puzzleNameLabel: UILabel?
    @IBOutlet weak var nodeCountLabel: UILabel?
    @IBOutlet weak var algorithmSelect: UISegmentedControl?
    
    @IBOutlet weak var undoButton: UIButton?
    @IBOutlet weak var solveButton: UIButton?
    
    @IBOutlet weak var rowSwitch: UISwitch?
    @IBOutlet weak var columnSwitch: UISwitch?
    @IBOutlet weak var blockSwitch: UISwitch?
    
    
    @IBAction func undoAction(sender:UISwitch)
    {
        print( "HLSolverViewController-  undoAction" )
        _solver.dataSet = _solver.previousDataSet
        updateAndDisplayCells()
        
        undoButton!.enabled = false
    }
    
    
    @IBAction func readAction()
    {
        _solver.read()
        puzzleNameLabel!.text = _solver.puzzleName
        updateAndDisplayCells()
    }
    
    
    @IBAction func writeAction()
    {
        
        _solver.save()
    }

    
    @IBAction func settingsAction()
    {
        rowsSelected    = rowSwitch!.on
        columnsSelected = columnSwitch!.on
        blocksSelected  = blockSwitch!.on
        
        defaults.setBool(!rowsSelected,     forKey:rowSwitchKey )
        defaults.setBool(!columnsSelected,  forKey:columnSwitchKey )
        defaults.setBool(!blocksSelected,   forKey:blockSwitchKey )
    }
    
    
    @IBAction func modeSelectAction()
    {
        defaults.setInteger(algorithmSelect!.selectedSegmentIndex, forKey: moodeSelectKey)
    }
    
    
    @IBAction func solveAction(sender:UIButton)
    {
         
        _solver.previousDataSet = _solver.dataSet

       switch( algorithmSelect!.selectedSegmentIndex )
        {
            case 0:     //  Mono Cell
                _solver.findMonoCells(rows: rowsSelected, columns: columnsSelected)
                break
            
            case 1:     //  Find Sets
                _solver.findPuzzleSets(rows: rowsSelected, columns: columnsSelected, blocks: blocksSelected)
                break
            
            case 2:     //  Mono Sectors
                _solver.findMonoSectors(rows: rowsSelected, columns: columnsSelected)
                break
            
            case 3:     //  Prune
                _solver.prunePuzzle(rows: rowsSelected, columns: columnsSelected, blocks: blocksSelected)
                break
            
            default:
                break
        }
        
        updateAndDisplayCells()
    }
    
    
    func updateAndDisplayCells()    {
        _solver.updateChangedCells()
        collectionView?.reloadData()
        let unsolvedCount = _solver.unsolvedCount()
        nodeCountLabel!.text = "Unsolved Nodes: \(unsolvedCount)"
        
        undoButton!.enabled = true
        if unsolvedCount == 0   {   solveButton!.enabled = false    }
        else                    {   solveButton!.enabled = true     }
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section:Int)->Int
    {
        return _solver.kCellCount
    }


    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath:NSIndexPath)->UICollectionViewCell
    {

        let  cell = collectionView.dequeueReusableCellWithReuseIdentifier("HLPuzzleCell",
                                        forIndexPath: indexPath) as! HLCollectionViewCell
        
        let (_, status) = _solver.dataSet[indexPath.row]
        
        cell.hlLabel!.text = _solver.dataSet.description(indexPath.row)

       switch status {
            
            case .CMGGivenStatus:
                cell.hlLabel!.textColor = UIColor.brownColor()
        
            case .CMGSolvedStatus:
                cell.hlLabel!.textColor = UIColor.greenColor()
        
            case .CMGChangedStatus:
                cell.hlLabel!.textColor = UIColor.redColor()
        
            case .CMGUnSolvedStatus:
                cell.hlLabel!.textColor = UIColor.blueColor()
        }

        return cell
    }


    override func viewDidLoad()     {
        super.viewDidLoad()

        let nib = UINib(nibName:"HLCollectionViewCell", bundle:nil)
        collectionView!.registerNib(nib, forCellWithReuseIdentifier:"HLPuzzleCell")
        
        algorithmSelect!.selectedSegmentIndex = defaults.integerForKey(moodeSelectKey)
        rowsSelected        = !defaults.boolForKey(rowSwitchKey)
        columnsSelected     = !defaults.boolForKey(columnSwitchKey)
        blocksSelected      = !defaults.boolForKey(blockSwitchKey)
        rowSwitch!.on       = rowsSelected
        columnSwitch!.on    = columnsSelected
        blockSwitch!.on     = blocksSelected
        
        _solver.puzzleName = puzzleName
        puzzleNameLabel!.text = _solver.puzzleName
        undoButton!.enabled = false
        
//        _solver.read()
//        updateAndDisplayCells()
//        _solver.findSetsForRow(0, sizeOfSet: 3)
//        updateAndDisplayCells()

        _solver.load(importArray)
        _solver.prunePuzzle(rows:true, columns:true, blocks:true)
        nodeCountLabel!.text = "Unsolved Nodes: \(_solver.unsolvedCount())"
    }
}
