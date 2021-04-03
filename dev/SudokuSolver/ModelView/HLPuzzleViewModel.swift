//
//  HLPuzzleViewModel.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 3/24/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import Foundation
import WebKit

class HLPuzzleViewModel: NSObject, ObservableObject, PuzzleFactoryProtocol {

    @Published var solver = HLSolver()
    @Published var algorithmSelected: HLAlgorithmMode = .monoCell
    @Published var testRows = true
    @Published var testColumns = true
    @Published var testBlocks = true
    @Published var undoButtonEnabled = false
    
    var puzzleFactory = PuzzleFactory()
    var previousState = HLPuzzleState.initial

    let hlKeySettingRow         = "hlKeySettingRow"
    let hlKeySettingColumn      = "hlKeySettingColumn"
    let hlKeySettingBlock       = "hlKeySettingBlock"
    let hlKeySettingAlgorithm   = "hlKeySettingAlgorithm"
        
    func puzzleReady(puzzle: HLSolver?) {
        if let puzzle = puzzle {
            print("puzzleReady: \(puzzle)")
            
            //*******************************************************
            //  replacing solver object will break the SwiftUI!!
            //  self.solver = puzzle
            //*******************************************************

            self.solver.dataSet = puzzle.dataSet
            self.solver.puzzleName = puzzle.puzzleName
            self.solver.puzzleState = puzzle.puzzleState
        }
    }

    func solveAction() {
        solver.previousDataSet = solver.dataSet
        previousState = solver.puzzleState  //  needed for the Undo button after initial Prune operation
        
        if solver.puzzleState == .initial {
            if !solver.prunePuzzle(rows: true, columns: true, blocks: true) {
                print("Serious ERROR:  Puzzle data not valid!")
            }
            solver.markSolvedCells()
        }
        else {
            switch algorithmSelected {
                case HLAlgorithmMode.monoCell:
                    solver.findMonoCells(rows: testRows, columns: testBlocks)
                
                case HLAlgorithmMode.findSets:
                    solver.findPuzzleSets(rows: testRows, columns: testColumns, blocks: testBlocks)
                
                case HLAlgorithmMode.monoSector:
                    solver.findMonoSectors(rows: testRows, columns: testColumns)
            }
            
            solver.updateChangedCells()
       }
        
        undoButtonEnabled = true
        saveSetting()   //  TODO:  find a cleaner solution
        
        if solver.puzzleState == .initial {
            solver.puzzleState = .solving
        }
    }
    
    func undoAction() {
        undoButtonEnabled = false
        solver.dataSet = solver.previousDataSet
        solver.puzzleState = previousState  //  will have effect if last operation was Prune
        solver.updateUnsolvedCount()
    }
    
    func saveSetting() {
        //  by negating the returned value we change the default to true
        UserDefaults.standard.set(!testRows, forKey: hlKeySettingRow)
        UserDefaults.standard.set(!testColumns, forKey: hlKeySettingColumn)
        UserDefaults.standard.set(!testBlocks, forKey: hlKeySettingBlock)
        UserDefaults.standard.set(algorithmSelected.rawValue, forKey: hlKeySettingAlgorithm)
    }
    
    func getNewPuzzle() {
        solver.puzzleState = .initial
        solver.puzzleName = " "
        undoButtonEnabled = false
        puzzleFactory.getNewPuzzle()
        
        //  use to fetch specific puzzle
        //     puzzleFactory.getNewPuzzle(puzzleId: "8543506682")
        //     puzzleFactory.getNewPuzzle(puzzleId: PuzzleFactory.test_data)
    }
    
    func replacePuzzleWithTestData() -> HLSolver {
        let dataSet = HLSolver.loadWithIntegerArray(HLSolver.testData)
        var solver = HLSolver(dataSet, puzzleName: "TestData", puzzleState: .solving)
        solver.prunePuzzle(rows: true, columns: true, blocks: true)
        return solver
    }

    deinit {
        saveSetting()
        print("HLPuzzleViewModel-  deinit")
    }
    
    override init() {
        print("HLPuzzleViewModel-  init")
        super.init()
        puzzleFactory.delegate = self
        getNewPuzzle()
        
        //  by negating the returned value we change the default to true
        testRows = !UserDefaults.standard.bool(forKey: hlKeySettingRow)
        testColumns = !UserDefaults.standard.bool(forKey: hlKeySettingColumn)
        testBlocks = !UserDefaults.standard.bool(forKey: hlKeySettingBlock)
        algorithmSelected = HLAlgorithmMode(rawValue: UserDefaults.standard.integer(forKey: hlKeySettingAlgorithm))!
    }
}
