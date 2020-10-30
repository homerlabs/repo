//
//  DataSet.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 10/30/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import Foundation

public struct HLDataSet: Codable {
    var data: [HLSudokuCell]

    //  dataset created by createValidSolvedPuzzle()
    //  1, 2, 3, 4, 5, 6, 7, 8, 9,
    //  2, 3, 4, 5, 6, 7, 8, 9, 1,
    //  3, 4, 5, 6, 7, 8, 9, 1, 2,
    //  4, 5, 6, 7, 8, 9, 1, 2, 3,
    //  5, 6, 7, 8, 9, 1, 2, 3, 4,
    //  6, 7, 8, 9, 1, 2, 3, 4, 5,
    //  7, 8, 9, 1, 2, 3, 4, 5, 6,
    //  8, 9, 1, 2, 3, 4, 5, 6, 7,
    //  9, 1, 2, 3, 4, 5, 6, 7, 8
    static public func createValidSolvedPuzzle() -> [HLSudokuCell] {
        var data: [HLSudokuCell] = []

        for row in 0..<HLSolver.kRows {
            for column in 0..<HLSolver.kColumns {
                let stringArray = [String((column+row) % 9 + 1)]
                let cellData = HLSudokuCell(data: Set(stringArray), status: HLCellStatus.givenStatus)
                data.append(cellData)
            }
        }
        
        return data
    }

    func printIndexDataSet(_ index:Int) {
        let cellData = self.data[index]
        print("\(cellData.setToString()) \t", terminator: "")
    }
    
    //  returns calculated index for a given row and column
    func indexFor(row: Int, column: Int) -> Int {
        row * HLSolver.kColumns + column
    }
    
    func printDataSet(_ dataSet: HLDataSet) {
        
        func printRowDataSet(_ dataSet: HLDataSet, row: Int)   {
            print("row: \(row) \t", terminator: "")
            for column in 0..<HLSolver.kColumns {
                let cellData = dataSet.data[(indexFor(row: row, column: column))]
                print("\(cellData.setToString()) \t", terminator: "")

            }
            print("")                   }
    
        //  start of func printDataSet()
        print("PrintDataSet")
        for row in 0..<HLSolver.kRows    {
            printRowDataSet(dataSet, row: row)
        }
        print("\n")
    }

    func printDataSet2()         {
        print("PrintDataSet2")
        for index in 0..<self.data.count    {
            printIndexDataSet(index)
        }
        print("")
    }
    
    init() {
        data = Array(repeating: HLSudokuCell(data: HLSolver.fullSet, status: HLCellStatus.unsolvedStatus), count: HLSolver.kCellCount)
    }
}

public struct HLSudokuCell: Codable {
    var data: Set<String>
    var status: HLCellStatus

    func setToString()-> String     {
        let list = Array(self.data.sorted(by: <))
        var returnString = ""
        if list.count <= 9   {
            for index in 0..<list.count     {
                returnString += list[index]
            }
        }
        return returnString
    }
    
}

