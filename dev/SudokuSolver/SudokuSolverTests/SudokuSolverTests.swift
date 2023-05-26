//
//  SudokuSolverTests.swift
//  SudokuSolverTests
//
//  Created by Matthew Homer on 3/23/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import XCTest
@testable import HLSudokuSolver

class SudokuSolverTests: XCTestCase, PuzzleFactoryProtocol {

    var solver = HLSolver()
    var puzzleFactory = PuzzleFactory()
    let expectationLoadPuzzle = XCTestExpectation(description: "Wait for puzzle to load")
    
    func testNewPuzzle() {
        puzzleFactory.getNewPuzzle(isOffline: false)
//     puzzleFactory.getNewPuzzle("8543506682")
        
        wait(for: [expectationLoadPuzzle], timeout: 7.0)
    }
    
    func puzzleReady(puzzle: HLSolver?) {
        if var puzzle = puzzle {
            print("puzzle: \(puzzle)")
            puzzle.fastSolve()
            print("puzzle: \(puzzle)")
            if puzzle.unsolvedNodeCount == 0 {
                expectationLoadPuzzle.fulfill()
            } else {
                XCTFail("Puzzle could not be solved.")
            }
        }
        else {
            XCTFail("Puzzle html could not be parsed.")
        }
        //  if I loop then www.sudoku.com will blacklist my IP address
  //      testNewPuzzle()
    }

    override func setUp() {
        puzzleFactory.delegate = self
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    //  dataset used by testPrunePuzzle()
    //  0, 2, 3, 4, 5, 6, 7, 8, 9,
    //  2, 0, 4, 5, 6, 7, 8, 9, 1,
    //  3, 4, 0, 6, 7, 8, 9, 1, 2,
    //  4, 5, 6, 0, 8, 9, 1, 2, 3,
    //  5, 6, 7, 8, 0, 1, 2, 3, 4,
    //  6, 7, 8, 9, 1, 0, 3, 4, 5,
    //  7, 8, 9, 1, 2, 3, 0, 5, 6,
    //  8, 9, 1, 2, 3, 4, 5, 0, 7,
    //  9, 1, 2, 3, 4, 5, 6, 7, 0
    func testPrunePuzzle() {
        var data = HLSudokuCell.createValidSolvedPuzzle()
        for index in 0..<HLSolver.numberOfCells {
            if (index % 10) == 0    {
                let cellData = HLSudokuCell(data: HLSolver.fullSet, status: .unsolvedStatus)
                data[index] = cellData
            }
        }
        
        var solver = HLSolver()
        solver.dataSet = data

        //  test row prune
        solver.prunePuzzle(rows: true, columns: false, blocks: false)
        XCTAssert(solver.unsolvedNodeCount == 0, "Pass")
        
        //  test column prune
        solver.dataSet = data
        solver.prunePuzzle(rows: false, columns: true, blocks: false)
        XCTAssert(solver.unsolvedNodeCount == 0, "Pass")
    }
    
    func test_convertColumnsToRows() {
        let data = Array(Range(1...81))
        let dataSet = HLSolver.loadWithIntegerArray(data)
        var solver = HLSolver(dataSet, puzzleName: "TestData", puzzleState: .initial)
   //     solver.printDataSet(solver.dataSet, desc: "pre convertColumnsToRows")
        solver.convertColumnsToRows()    //  convert columns to rows
   //     solver.printDataSet(solver.dataSet, desc: "post convertColumnsToRows1")
        XCTAssert(solver.dataSet != dataSet, "Fail")
        solver.convertColumnsToRows()    //  convert back rows to columns
   //     solver.printDataSet(solver.dataSet, desc: "post convertColumnsToRows2")
        XCTAssert(solver.dataSet == dataSet, "Pass")
    }
    
    func test_convertBlocksToRows() {
        let data = Array(Range(1...81))
        let dataSet = HLSolver.loadWithIntegerArray(data)
        var solver = HLSolver(dataSet, puzzleName: "TestData", puzzleState: .initial)
        solver.convertBlocksToRows()    //  convert blocks to rows
        XCTAssert(solver.dataSet != dataSet, "Fail")
        solver.convertBlocksToRows()    //  convert back rows to blocks
        XCTAssert(solver.dataSet == dataSet, "Pass")
    }
    
    func testUsingTestData() {
        let dataSet = HLSolver.loadWithIntegerArray(HLSolver.testData)
        var solver = HLSolver(dataSet, puzzleName: "TestData", puzzleState: .initial)

        solver.prunePuzzle(rows: true, columns: true, blocks: true)
        
        let valid2 = solver.isValidPuzzle()
        print("SudokuSolverTests-  valid2: \(valid2) unsolvedNodeCount: \(solver.unsolvedNodeCount)")
        solver.printDataSet(solver.dataSet)
        
        solver.findMonoCells(rows: true, columns: false)
        
        solver.printDataSet(solver.dataSet)
        solver.printDataSet(solver.dataSet)
    }
    
    func testIsPuzzleValid() {
        var solver = HLSolver()
        var data = HLSudokuCell.createValidSolvedPuzzle()
        solver.dataSet = data
        XCTAssert(solver.isValidPuzzle(), "Pass")
        
        data[0] = HLSudokuCell(data: Set(["6"]), status: .givenStatus)   //  should be 1
        solver.dataSet = data
        XCTAssert(!solver.isValidPuzzle(), "Pass")
    }
}
