//
//  HLSudokuCell.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 11/1/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import Foundation

public struct HLSudokuCell: Codable, Equatable {
//    static var counter = 0
    var data: Set<String>
    var status: HLCellStatus
    var id = 0
    
    init(data: Set<String>, status: HLCellStatus) {
        self.data = data
        self.status = status
    //    id = HLSudokuCell.counter
   //    print("HLSudokuCell- init  id: \(id)")
    //    HLSudokuCell.counter += 1
    }

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

        for row in 0..<HLSolver.numberOfRows {
            for column in 0..<HLSolver.numberOfColumns {
                let stringArray = [String((column+row) % 9 + 1)]
                let cellData = HLSudokuCell(data: Set(stringArray), status: HLCellStatus.givenStatus)
                data.append(cellData)
            }
        }
        
        return data
    }
    
    static public func createUnsolvedPuzzle() -> [HLSudokuCell] {
        let cellData = HLSudokuCell(data: HLSolver.fullSet, status: .unsolvedStatus)
        return Array(repeating: cellData, count: HLSolver.numberOfCells)
    }
}

extension HLSudokuCell {
    //  useful for creating test data
    init(intData: [Int], cellStatus: HLCellStatus) {
        let stringData = intData.map { String($0) }
        data = Set(stringData)
        status = cellStatus
     //   id = HLSudokuCell.counter
     //   HLSudokuCell.counter += 1
    }
}

/*extension HLSudokuCell: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.data == rhs.data && lhs.status == rhs.status
    }
}*/

extension HLSudokuCell: CustomStringConvertible {
    public var description: String {
        return "\(setToString())"
    }
}
