//
//  HLMatrix.swift
//  Sudoku Solver
//
//  Created by Matthew Homer on 7/20/15.
//  Copyright (c) 2015 Homer Labs. All rights reserved.
//

import Foundation


struct Matrix {
    let kRows: Int
    let kColumns: Int
    let kCellCount: Int

    var grid: [(Set<String>, HLCellStatus)]
    
    func nodeCount() -> Int {
        var count = 0
        for index in 0..<grid.count {
            let (data, _) = grid[index]
            count += data.count     }
        
        return count - kCellCount
    }
    
    
    func copy() -> Matrix {
        var newData = Matrix(rows:9, columns:9)
        for i in 0..<kCellCount     {
            newData.grid[i] = grid[i]
        }
        return newData
    }
    
    init(rows: Int, columns: Int) {
        kRows = rows
        kColumns = columns
        kCellCount = rows * columns
        
        grid = Array(repeating: (Set<String>(), .unsolvedStatus), count: kCellCount)
    }
    
    func description(_ index: Int) -> String {
        let (data, _) = grid[index]
        let sortedCell = Array(data).sorted(by: <)
        var outputString = String()
        
        for i in 0..<sortedCell.count {
            outputString += sortedCell[i]
        }

//        println(outputString)
        return outputString
    }
    
    func description(row: Int, column: Int) -> String {
        let (data, _) = grid[row*kColumns+column]
        let sortedCell = Array(data).sorted(by: <)
        var outputString = String()
        
        for i in 0..<sortedCell.count {
            outputString += sortedCell[i]
        }
        
        for _ in outputString.count..<10 {
            outputString += " "
        }

//        println("\n\(row)   \(column)   outputString: \(outputString)")
        return outputString
    }
    
    func indexIsValidForRow(_ row: Int) -> Bool   {
        return row>=0 && row<kRows              }
    
    func indexIsValidForColumn(_ column: Int) -> Bool {
        return column>=0 && column<kColumns         }
    
    subscript(row: Int, column: Int) -> (Set<String>, HLCellStatus) {
        get {
            assert(indexIsValidForRow(row), "Row index out of range")
            assert(indexIsValidForColumn(column), "Column index out of range")
            return grid[row*kColumns+column]
        }
        
        set {
            assert(indexIsValidForRow(row), "Row index out of range")
            assert(indexIsValidForColumn(column), "Column index out of range")
            grid[(row*kColumns)+column] = newValue
        }
    }
    
    func indexIsValidForCell(_ index: Int) -> Bool {
        return index>=0 && index<kCellCount
    }
    
    subscript(index: Int) -> (Set<String>, HLCellStatus) {
        get {
            assert(indexIsValidForCell(index), "Index outy of range")
            return grid[index]
        }
        
        set {
            assert(indexIsValidForCell(index), "Index outy of range")
            grid[index] = newValue
        }
    }
}
