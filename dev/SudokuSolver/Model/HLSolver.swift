//
//  HLSolver.swift
//  Sudoku Solver
//
//  Created by Matthew Homer on 7/13/15.
//  Copyright (c) 2015 Homer Labs. All rights reserved.
//

import Foundation


public enum HLCellStatus: Int, Codable
{
    case givenStatus
    case unsolvedStatus
    case changedStatus
    case solvedStatus   //  keep this one last as its used as enum count
}

public enum HLAlgorithmMode: Int, Codable
{
    case monoCell
    case findSets
    case monoSector
}

public enum HLPuzzleState: Int, Codable
{
    case initial
    case solving
    case final
}

public class HLSolver: Codable {
    var dataSet: [HLSudokuCell]
    var previousDataSet: [HLSudokuCell]
    var puzzleName: String
    var puzzleState: HLPuzzleState
    var unsolvedNodeCount = 0

    static let websudokuURL = URL(string: "https://nine.websudoku.com/?level=4")!
//    static let websudokuURL = URL(string: "https://nine.websudoku.com/?level=4&set_id=8543506682")!
    //  5433300902  can't solve

    static let numberOfRows = 9
    static let numberOfColumns = 9
    static let numberOfCells = 81
    static let fullSet = Set<String>(["1", "2", "3", "4", "5", "6", "7", "8", "9"])
    static let puzzleDataKey = "puzzleDataKey"

    static let testData: [Int] = [
        0, 0, 0, 1, 2, 8, 7, 4, 3,
        1, 8, 7, 9, 3, 4, 2, 5, 6,
        3, 2, 4, 5, 7, 6, 8, 1, 9,
        
        0, 7, 8, 0, 0, 3, 5, 6, 1,
        0, 0, 0, 0, 0, 1, 9, 0, 2,
        2, 3, 1, 6, 0, 5, 4, 0, 7,
        
        7, 1, 6, 8, 5, 9, 3, 2, 4,
        8, 9, 3, 4, 0, 2, 6, 7, 5,
        5, 4, 2, 3, 6, 7, 1, 9, 8
    ]

    //  this is used to re-map the blocks to look like rows before a row operation and then re-map back
    static let blockIndexSet = [
        [ 0,  1,  2,  9, 10, 11, 18, 19, 20],
        [ 3,  4,  5, 12, 13, 14, 21, 22, 23],
        [ 6,  7,  8, 15, 16, 17, 24, 25, 26],
        
        [27, 28, 29, 36, 37, 38, 45, 46, 47],
        [30, 31, 32, 39, 40, 41, 48, 49, 50],
        [33, 34, 35, 42, 43, 44, 51, 52, 53],
        
        [54, 55, 56, 63, 64, 65, 72, 73, 74],
        [57, 58, 59, 66, 67, 68, 75, 76, 77],
        [60, 61, 62, 69, 70, 71, 78, 79, 80]
    ]

    func indexFor(row: Int, column: Int) -> Int {
        row * HLSolver.numberOfColumns + column
    }
        
    func findMonoCells(rows: Bool, columns: Bool)   {
    
        func monoCellRows()                 {
        
            func monoCell(_ row: Int)         {
                var numArray = Array(repeating: 0, count: 10)
                for column in 0..<HLSolver.numberOfColumns     {
                    let cellData = dataSet[indexFor(row: row, column: column)]
                    if cellData.data.count > 1 {
                        for item: String in cellData.data {
                            if let index = Int(item) {
                                let num = numArray[index] + 1
                                numArray[index] = num
                            }
                        }
                    }
                }
                
                for index in 1...9 {
                    if numArray[index] == 1 {
                        for column in 0..<HLSolver.numberOfColumns     {
                            let cellIndex = indexFor(row: row, column: column)
                            let cellData = dataSet[cellIndex]
                            let solutionSet: Set<String> = Set(arrayLiteral: String(index))
                            let newSet = cellData.data.intersection(solutionSet)
                            if !newSet.isEmpty {
                                dataSet[cellIndex] = HLSudokuCell(data: newSet, status: .solvedStatus)
                            }
                        }
                    }
                }
           }
            
            //  start of monoCellRows
       //     print("monoCellRows")
            for row in 0..<HLSolver.numberOfRows    {
                //  make sure puzzle data still valid then perform call to monoCell(row)
                if prunePuzzle(rows: true, columns: true, blocks: true) {
                    monoCell(row)
                }
            }
            
            //  prune data before returning
            prunePuzzle(rows: true, columns: true, blocks: true)
        }
    
        func monoCellColumns()      {
            convertColumnsToRows()
            monoCellRows()
            convertColumnsToRows()  }

        //  start of func findMonoCells()
        print("findMonoCells")
        if rows     {   monoCellRows()    }
        if columns  {   monoCellColumns() }
    }
        
    func findMonoSectors(rows: Bool, columns: Bool)  {

        func reduceMonoSectorsForRows()     {
            
            //  returns an array of found MonoSectors as a tuple (num, sector)
            func findMonoSectorForRow(_ row: Int) -> [(Int, Int)]    {
   //             print("monoSector")
                
                var foundMonoSectors: [(Int, Int)] = Array()
                let sectorNotFound = -1     //  anything but 0-2
                
                for num in 1...9    {
                    
                    var sector = sectorNotFound
                    for column in 0..<HLSolver.numberOfColumns
                    {
                        let cellData = dataSet[indexFor(row: row, column: column)]
                        if cellData.data.count>1
                        {
                            if cellData.data.contains(String(num))   {
                            
                                if sector == sectorNotFound {
                                    sector = sectorForIndex(column)
                                }
                                else if sector != sectorForIndex(column)    {
                                    sector = sectorNotFound     //  no mono sector here
                                    break
                                }
                            }
                        }
                    }
                    
                    if sector != sectorNotFound     {
                        foundMonoSectors.append((num, sector))
           //             print("foundMonoSectors: \(row)   foundMonoSectors: \(foundMonoSectors)")
                    }
                }
             
                return foundMonoSectors
            }
    
            func reduceBlockForRow(_ row: Int, sector: Int, reduceNumber: Int)    {
                
                func reduceRowForRow(_ row: Int, sector: Int, reduceNumber: Int)    {
                    var column = sector * 3
                    var cellData = dataSet[indexFor(row: row, column: column)]
                    cellData.data.remove(String(reduceNumber))
                    dataSet[indexFor(row: row, column: column)] = cellData

                    column += 1
                    cellData = dataSet[indexFor(row: row, column: column)]
                    cellData.data.remove(String(reduceNumber))
                    dataSet[indexFor(row: row, column: column)] = cellData

                    column += 1
                    cellData = dataSet[indexFor(row: row, column: column)]
                    cellData.data.remove(String(reduceNumber))
                    dataSet[indexFor(row: row, column: column)] = cellData
                }
                
                //  start of func reduceBlockForRow()
                var reduceRow = sectorForIndex(row) * 3
                if row != reduceRow  {
                    reduceRowForRow(reduceRow, sector: sector, reduceNumber: reduceNumber)  }
                
                reduceRow += 1
                if row != reduceRow  {
                    reduceRowForRow(reduceRow, sector: sector, reduceNumber: reduceNumber)  }
                
                reduceRow += 1
                if row != reduceRow  {
                    reduceRowForRow(reduceRow, sector: sector, reduceNumber: reduceNumber)  }
            }

            for row in 0..<HLSolver.numberOfRows    {
                
                let foundSet = findMonoSectorForRow(row)
             //   print("foundSet: \(foundSet)")
                
                for item in foundSet {
               //     print("foundMonoSectors: \(row)   item: \(item)")
                    reduceBlockForRow(row, sector: item.1, reduceNumber: item.0)
                }
                
                prunePuzzle(rows: true, columns: true, blocks: true)
            }
        }

        func reduceMonoSectorsForColumns()    {
            convertColumnsToRows()
            reduceMonoSectorsForRows()
            convertColumnsToRows()
        }
        
        //  start of func findMonoSectors()
        print("findMonoSectors")
        if rows     {   reduceMonoSectorsForRows()    }
        if columns  {   reduceMonoSectorsForColumns() }
    }
        
    func findPuzzleSets(rows: Bool, columns: Bool, blocks: Bool)  {

        func findSetsForRow(_ row: Int, sizeOfSet: Int)  {
            
      //      fillRow()
            var startingSets:   [Set<String>] = [Set<String>()]
            var setsToSearch:   [Set<String>] = [Set<String>()]
            
            for column in 0..<HLSolver.numberOfColumns  {
                let cellData = dataSet[indexFor(row: row, column: column)]
                if cellData.data.count == sizeOfSet  {   setsToSearch.append(cellData.data)   }
                if cellData.data.count > 1           {   startingSets.append(cellData.data)   }
            }
            
            if startingSets.count > 1 && startingSets[0].isEmpty  {   startingSets.remove(at: 0)   }
            if setsToSearch.count > 1 && setsToSearch[0].isEmpty  {   setsToSearch.remove(at: 0)   }
            
            for superSet in setsToSearch                                {
                
     //           print( "superSet: \(superSet):")
                let didFindSet = searchForSets(startingSets, superSet: superSet, count: sizeOfSet)
                if didFindSet { reduceRow(row, forSet: superSet)    }   }
        }
        
        func findSetsForBlocks()    {
            convertBlocksToRows()
            for setSize in 2..<4                                                        {
                for row in 0..<HLSolver.numberOfRows    {   findSetsForRow(row, sizeOfSet:setSize)  }   }
            convertBlocksToRows()   }
        
        
        func findSetsForColumns()   {
            convertColumnsToRows()
            for setSize in 2..<4                                                        {
                for row in 0..<HLSolver.numberOfRows    {   findSetsForRow(row, sizeOfSet:setSize)  }   }
            convertColumnsToRows()  }
        
        
        func findSetsForRows()    {
            for setSize in 2..<4                                                        {
                for row in 0..<HLSolver.numberOfRows    {   findSetsForRow(row, sizeOfSet:setSize)  }   }
        }
        
        //  start of func findPuzzleSets()
        print("findPuzzleSets")
        if rows     {   findSetsForRows()    }
        if columns  {   findSetsForColumns() }
        if blocks   {   findSetsForBlocks()  }

        prunePuzzle(rows:true, columns:true, blocks:true)
    }
    
    //  prunePuzzle() calls itself until node count remains unchanged
    //  returns true if puzzle still valid
    @discardableResult func prunePuzzle(rows: Bool, columns: Bool, blocks: Bool) -> Bool  {

        func prunePuzzleRows()   {
            if
                !isValidPuzzle() {
                print("pre-prunePuzzleRows-  prunePuzzleRows made puzzle data invalid")
            }

            for row in 0..<HLSolver.numberOfRows {
                let solvedSet = solvedSetForRow(row)
        //        print("row: \(row)   solvedSet: \(solvedSet)")

                for column in 0..<HLSolver.numberOfColumns  {
                    let index = indexFor(row: row, column: column)
                    var cellData = dataSet[index]
                    
                    //  don't modify if cell already solved
                    if cellData.data.count > 1 {
                        cellData.data = cellData.data.subtracting(solvedSet)
                        dataSet[index] = cellData
                    }
                }
            }
            
            if
                !isValidPuzzle() {
                print("post-prunePuzzleRows-  prunePuzzleRows made puzzle data invalid")
            }
       }
    
        func prunePuzzleColumns()   {
            convertColumnsToRows()
            prunePuzzleRows()
            convertColumnsToRows()  }
        
        func prunePuzzleBlocks()    {
            convertBlocksToRows()
            prunePuzzleRows()
            convertBlocksToRows()
        }

        //  start of func prunePuzzle(
        guard isValidPuzzle() else  {  return false    }
        
        var currentNodeCount = updateUnsolvedCount()
        var previousNodeCount = currentNodeCount

        repeat  {
            previousNodeCount = currentNodeCount

            if rows     {   prunePuzzleRows()    }
            if columns  {   prunePuzzleColumns() }
            if blocks   {   prunePuzzleBlocks()  }

            currentNodeCount = updateUnsolvedCount()

            if !isValidPuzzle() {
                return false
            }
        }
        while previousNodeCount != currentNodeCount
        
        return true
    }
    
    func searchForSets(_ setsToSearch: [Set<String>], superSet: Set<String>, count: Int) -> Bool {
 //       print( "searchForSets: \(setsToSearch)   count: \(count)")
        
        var remainingSets = setsToSearch
        var item = remainingSets.removeLast()
        
        //  remove cells that are not subset
        while !item.isSubset(of: superSet) && !remainingSets.isEmpty  {
            item = remainingSets.removeLast()                       }
        
        if !item.isSubset(of: superSet)   {   return false    }
        
        if count>1 && !remainingSets.isEmpty                                        {
            return searchForSets(remainingSets, superSet: superSet, count: count-1)
        }
        
        else if count == 1      {   return true     }
        else                    {   return false    }
    }
    
    func reduceRow(_ row: Int, forSet reduceSet: Set<String>)    {
 //       print( "reduceRow: \(row)   reduceSet: \(reduceSet)")

        for column in 0..<HLSolver.numberOfColumns  {
            var cellData = dataSet[indexFor(row: row, column: column)]
            if cellData.data.count>1                            {
                cellData.data = cellData.data.subtracting(reduceSet)
                
                if !cellData.data.isEmpty  {
                    dataSet[indexFor(row: row, column: column)] = cellData
                }
            }
        }
    }
    
    //  check for cells that have only 1 value (ie .solved)
    func markSolvedCells() {
        for index in 0..<HLSolver.numberOfCells {
            var cellData = dataSet[index]
            
            if cellData.data.count == 1 && cellData.status == .unsolvedStatus   {
                cellData.status = .solvedStatus
                dataSet[index] = cellData
            }
        }
    }
    
    func updateChangedCells()   {
        for index in 0..<HLSolver.numberOfCells {
            var cellData = dataSet[index]
            let previousCellData = previousDataSet[index]
            
            //  first lets convert Changed to Solved or Unsollved
            if cellData.status == .changedStatus {
                if cellData.data.count == 1  {  cellData.status = .solvedStatus }
                else                         {   cellData.status = .unsolvedStatus }
                dataSet[index] = cellData
            }
            
            //  then find the cells that changed
            if puzzleState == .solving && cellData.data.count != previousCellData.data.count     {
                cellData.status = .changedStatus
                dataSet[index] = cellData
            }
        }
        
        markSolvedCells()
    }

    //  when count reaches zero set puzzleState to .final
    //  returns nodeCount
    @discardableResult func updateUnsolvedCount() -> Int
    {
        var count = 0
        for index in 0..<HLSolver.numberOfCells {
            let cellData = dataSet[index]
            count += cellData.data.count     }
        
        unsolvedNodeCount = count - HLSolver.numberOfCells

        if unsolvedNodeCount == 0 {
            puzzleState = .final
        }
        
        return count
    }
        
    func solvedSetForRow(_ row: Int) -> Set<String>       {
        var solvedSet = Set<String>()
        for column in 0..<HLSolver.numberOfColumns                      {
            let cellData = dataSet[indexFor(row: row, column: column)]
            if cellData.data.count == 1  {
                solvedSet = solvedSet.union(cellData.data)
            }
        }
        
        return solvedSet
    }

    func convertColumnsToRows() {
        let dataSetCopy = dataSet
        for row in 0..<HLSolver.numberOfRows   {
            for column in 0..<HLSolver.numberOfColumns {
                //  notice the row - column switch for dataSetCopy
                dataSet[indexFor(row: row, column: column)] = dataSetCopy[indexFor(row: column, column: row)]
            }
        }
    }
        
    func convertBlocksToRows() {
        let dataSetCopy = dataSet
        for row in 0..<HLSolver.numberOfRows {
            let blockSet = HLSolver.blockIndexSet[row]
            for column2 in 0..<HLSolver.numberOfRows {
                dataSet[indexFor(row: row, column: column2)] = dataSetCopy[blockSet[column2]]
            }
        }
    }

    @discardableResult func isValidPuzzle() -> Bool {
    
        func isValidPuzzleRow(_ row: Int) -> Bool {
            var returnValue = true
            var numArray = Array(repeating: 0, count: 10)
                
            for column in 0..<HLSolver.numberOfColumns {
            
                let cellData = dataSet[indexFor(row: row, column: column)]
                let cell = Array(cellData.data)
                if cell.count == 1 {
                    let value = cell[0]
                    numArray[Int(value)!] += 1
                }
            }
            
            for i in 0..<numArray.count {
                if numArray[i] > 1 {
                    returnValue = false
                    print("Puzzle \(puzzleName) not valid!  row: \(row)   i: \(i)   numArray[i]: \(numArray[i])")
                    printDataSet(previousDataSet)
                    printDataSet(dataSet)
                    break
                }
            }

            return returnValue
        }

        //  beginning of isValidPuzzle()
        var isValid = true
        for row in 0..<HLSolver.numberOfRows {
            if !isValidPuzzleRow(row) {
                isValid = false
                print("Puzzle \(puzzleName) not valid!  row: \(row)")
                break
            }
        }
        
        if !isValid {
            printDataSet(dataSet)
            print("Puzzle \(puzzleName) not valid!  Saving previousDataSet...")
  //          saveData(previousDataSet)
     //       assert( false, "Puzzle \(puzzleName) is not valid!" )
        }

        return isValid
    }

    func sectorForIndex(_ index: Int) -> Int    {
        return index/3
    }

    func unsolvedCount(_ dataSet: [HLSudokuCell]) -> Int {
        var count = 0
        for index in 0..<HLSolver.numberOfCells {
                let cellData = dataSet[index]
            count += cellData.data.count
        }
        
        return count - HLSolver.numberOfCells
    }

    func printDataSet(_ dataSet: [HLSudokuCell]) {
        
        func printRowDataSet(_ dataSet: [HLSudokuCell], row: Int)   {
            print("row: \(row) \t", terminator: "")
            for column in 0..<HLSolver.numberOfColumns {
                let cellData = dataSet[(indexFor(row: row, column: column))]
                print("\(cellData.setToString()) \t", terminator: "")

            }
            print("")                   }
    
        //  start of func printDataSet()
        print("PrintDataSet-  dataSet unsolvedNodeCount: \(unsolvedCount(dataSet))")
        for row in 0..<HLSolver.numberOfRows    {  printRowDataSet(dataSet, row: row)    }
        print("\n")
    }

    func saveData(_ dataSet: [HLSudokuCell]) {
        print( "HLSolver-  saveData:  \(puzzleName)" )
        
        let solver = HLSolver(dataSet, puzzleName: puzzleName, puzzleState: puzzleState)
        let plistEncoder = PropertyListEncoder()
        if let data = try? plistEncoder.encode(solver) {
            UserDefaults.standard.set(data, forKey: HLSolver.puzzleDataKey)
        }
    }

    class func loadWithIntegerArray(_ data: [Int]) -> [HLSudokuCell]
    {
        var dataSet: [HLSudokuCell] = []

        if data.count == HLSolver.numberOfCells     {
            for item in data
            {
                let cellValue = item
                var newCell = HLSudokuCell(data: HLSolver.fullSet, status: .unsolvedStatus)
                
                if ( cellValue != 0 )     {
                    newCell = HLSudokuCell(data: Set([String(cellValue)]), status: .givenStatus)
                }
                
                dataSet.append(newCell)
            }
        }
        
        return dataSet
    }

    func loadData() -> HLSolver?  {
            
        var solver: HLSolver?
        if let data = UserDefaults.standard.data(forKey: HLSolver.puzzleDataKey)    {
            let plistDecoder = PropertyListDecoder()
            solver = try? plistDecoder.decode(HLSolver.self, from:data)
     //       solver?.printDataSet(solver!.dataSet)
        }
        
        print( "HLSolver-  loadData: \(String(describing: solver?.puzzleName))" )
        return solver
    }

    convenience init() {
     //   print("HLSolver-  init")
        self.init(HLSudokuCell.createUnsolvedPuzzle(), puzzleName: "No Puzzle Found", puzzleState: .initial)
    }

    init(_ dataSet: [HLSudokuCell], puzzleName: String, puzzleState: HLPuzzleState) {
        print("HLSolver-  initWithDataSet: puzzleName: \(puzzleName)")
        self.dataSet = dataSet
        self.puzzleName = puzzleName
        self.puzzleState = puzzleState
        previousDataSet = dataSet
        updateUnsolvedCount()
    }
    
    deinit {
        print("HLSolver-  deinit")
    }
}
