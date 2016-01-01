//
//  Sudoku_SolverTests.swift
//  Sudoku SolverTests
//
//  Created by Matthew Homer on 7/13/15.
//  Copyright (c) 2015 Homer Labs. All rights reserved.
//

import UIKit
import XCTest

class Sudoku_SolverTests: XCTestCase {

    //  0, 2, 3, 4, 5, 6, 7, 8, 9,
    //  2, 0, 4, 5, 6, 7, 8, 9, 1,
    //  3, 4, 0, 6, 7, 8, 9, 1, 2,
    //  4, 5, 6, 0, 8, 9, 1, 2, 3,
    //  5, 6, 7, 8, 0, 1, 2, 3, 4,
    //  6, 7, 8, 9, 1, 0, 3, 4, 5,
    //  7, 8, 9, 1, 2, 3, 0, 5, 6,
    //  8, 9, 1, 2, 3, 4, 5, 0, 7,
    //  9, 1, 2, 3, 4, 5, 6, 7, 0
    func testPrunePuzzle()  {
    
        let solver = HLSolver()
        
        var puzzleData = createValidSolvedPuzzle()
        
        for index in 0...80 {
            if (index % 10) == 0    {   puzzleData[index] = "0"     }
        }

        solver.load(puzzleData)
        solver.prunePuzzle(rows: true, columns: false, blocks: false)
        XCTAssert(solver.unsolvedCount()==0, "Pass")

        solver.load(puzzleData)
        solver.prunePuzzle(rows: false, columns: true, blocks: false)
        XCTAssert(solver.unsolvedCount()==0, "Pass")
    }

    //  tests the isPuzzleValid function
    func testIsPuzzleValid() {

        let solver = HLSolver()
        
        var puzzleData = createValidSolvedPuzzle()
        solver.load(puzzleData)
        XCTAssert(solver.isValidPuzzle(), "Pass")

        puzzleData[0] = "6" //  should be "1"
        solver.load(puzzleData)
        XCTAssert(!solver.isValidPuzzle(), "Pass")
    }
    
    //  1, 2, 3, 4, 5, 6, 7, 8, 9,
    //  2, 3, 4, 5, 6, 7, 8, 9, 1,
    //  3, 4, 5, 6, 7, 8, 9, 1, 2,
    //  4, 5, 6, 7, 8, 9, 1, 2, 3,
    //  5, 6, 7, 8, 9, 1, 2, 3, 4,
    //  6, 7, 8, 9, 1, 2, 3, 4, 5,
    //  7, 8, 9, 1, 2, 3, 4, 5, 6,
    //  8, 9, 1, 2, 3, 4, 5, 6, 7,
    //  9, 1, 2, 3, 4, 5, 6, 7, 8
    func createValidSolvedPuzzle() -> [String]
    {
        var dataArray = [String](count: 81, repeatedValue: "0" )
        
        for row in 0...8    {
            for column in 0...8 {
                dataArray[row*9+column] = String((column+row) % 9 + 1)
            }
        }
        
        return dataArray
    }
}
