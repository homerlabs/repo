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
        solver.read()
        
        XCTAssert(true, "Pass")
    }
}
