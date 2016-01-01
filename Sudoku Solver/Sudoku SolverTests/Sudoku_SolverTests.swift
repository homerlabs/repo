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

    //  tests the isPuzzleValid method
    func testIsPuzzleValid() {

        let solver = HLSolver()
        
        var puzzleData = createValidSolvedPuzzle()
//        print(puzzleData)

        solver.load(puzzleData)
        let isValid = solver.isValidPuzzle()
        XCTAssert(isValid, "Pass")

        puzzleData[0] = "6" //  should be "1"
        solver.load(puzzleData)
        let isNotValid = !solver.isValidPuzzle()
        XCTAssert(isNotValid, "Pass")
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
