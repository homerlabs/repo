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

enum CodingKeys: String, CodingKey {
    case puzzleName
    case puzzleState
    case puzzleDataSet
}


public class HLSolver: Codable {
    static let websudokuURL = URL(string: "https://nine.websudoku.com/?level=4")!
//    static let websudokuURL = URL(string: "https://nine.websudoku.com/?level=4&set_id=8543506682")!

    //  used for encode/decode HLSolver object
    let kDataKey   = "DataKey"
    let kStateKey  = "StateKey"
    let kNameKey   = "NameKey"
    
    static let kRows = 9
    static let kColumns = 9
    static let kCellCount = 81
    static let fullSet = Set<String>(["1", "2", "3", "4", "5", "6", "7", "8", "9"])

    var dataSet = HLDataSet()
    var previousDataSet = HLDataSet()
    var puzzleName = "No Puzzle Found"
    var puzzleState = HLPuzzleState.initial
        
    //  this is used to re-map the blocks to look like rows before a row operation and then re-map back
    let blockIndexSet = [
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
        row * HLSolver.kColumns + column
    }
    
    
    func findMonoCells(rows: Bool, columns: Bool)   {
    
        func monoCellRows()                 {
        
            func monoCell(_ row: Int)         {
                var numArray = Array(repeating: 0, count: 10)
                for column in 0..<HLSolver.kColumns     {
                    let cellData = dataSet.data[indexFor(row: row, column: column)]
                    if cellData.data.count > 1                                              {
                        for item: String in cellData.data {  numArray[Int(item)!] += 1   }   }
                }
                
                for index in 1...9 {
                    if numArray[index] == 1 {
                        for column in 0..<HLSolver.kColumns     {
                            let index = indexFor(row: row, column: column)
                            let cellData = dataSet.data[index]
                            let solutionSet: Set<String> = Set(arrayLiteral: String(index))
                            let newSet = cellData.data.intersection(solutionSet)
                            if !newSet.isEmpty {
                print("monoCellRows-  row: \(row)   column: \(column)   newSet: \(newSet)")
                                dataSet.data[index] = HLSudokuCell(data: newSet, status: .solvedStatus)
                            }
                        }
                    }
                }
                
                prunePuzzle(rows: true, columns: true, blocks: true)
           }
            
            //  start of monoCellRows
       //     print("monoCellRows")
            for row in 0..<HLSolver.kRows    {
                monoCell(row)
            }
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
                    for column in 0..<HLSolver.kColumns
                    {
                        let cellData = dataSet.data[indexFor(row: row, column: column)]
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
                    var cellData = dataSet.data[indexFor(row: row, column: column)]
                    cellData.data.remove(String(reduceNumber))
                    dataSet.data[indexFor(row: row, column: column)] = cellData

                    column += 1
                    cellData = dataSet.data[indexFor(row: row, column: column)]
                    cellData.data.remove(String(reduceNumber))
                    dataSet.data[indexFor(row: row, column: column)] = cellData

                    column += 1
                    cellData = dataSet.data[indexFor(row: row, column: column)]
                    cellData.data.remove(String(reduceNumber))
                    dataSet.data[indexFor(row: row, column: column)] = cellData
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

            for row in 0..<HLSolver.kRows    {
                
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
            
            for column in 0..<HLSolver.kColumns  {
                let cellData = dataSet.data[indexFor(row: row, column: column)]
                if cellData.data.count == sizeOfSet  {   setsToSearch.append(cellData.data)   }
                if cellData.data.count>1             {   startingSets.append(cellData.data)   }
            }
            
            if startingSets.count>1 && startingSets[0].isEmpty  {   startingSets.remove(at: 0)   }
            if setsToSearch.count>1 && setsToSearch[0].isEmpty  {   setsToSearch.remove(at: 0)   }
            
            for superSet in setsToSearch                                {
                
     //           print( "superSet: \(superSet):")
                let didFindSet = searchForSets(startingSets, superSet: superSet, count: sizeOfSet)
                if didFindSet { reduceRow(row, forSet: superSet)    }   }
        }
        
        func findSetsForBlocks()    {
            convertBlocksToRows()
            for setSize in 2..<4                                                        {
                for row in 0..<HLSolver.kRows    {   findSetsForRow(row, sizeOfSet:setSize)  }   }
            convertBlocksToRows()   }
        
        
        func findSetsForColumns()   {
            convertColumnsToRows()
            for setSize in 2..<4                                                        {
                for row in 0..<HLSolver.kRows    {   findSetsForRow(row, sizeOfSet:setSize)  }   }
            convertColumnsToRows()  }
        
        
        func findSetsForRows()    {
            for setSize in 2..<4                                                        {
                for row in 0..<HLSolver.kRows    {   findSetsForRow(row, sizeOfSet:setSize)  }   }
        }
        
        //  start of func findPuzzleSets()
        print("findPuzzleSets")
        if rows     {   findSetsForRows()    }
        if columns  {   findSetsForColumns() }
        if blocks   {   findSetsForBlocks()  }

        prunePuzzle(rows:true, columns:true, blocks:true)
    }
    
    
    //  prunePuzzle() calls itself until node count remains unchanged
    func prunePuzzle(rows: Bool, columns: Bool, blocks: Bool)  {

        func prunePuzzleRows()                          {
            for row in 0..<HLSolver.kRows {
                let solvedSet = solvedSetForRow(row)
        //        print("row: \(row)   solvedSet: \(solvedSet)")

                for column in 0..<HLSolver.kColumns  {
                    let index = indexFor(row: row, column: column)
                    var cellData = dataSet.data[index]
                    
                    //  don't modify if cell already solved
                    if cellData.data.count > 1 {
                        cellData.data = cellData.data.subtracting(solvedSet)
                        dataSet.data[index] = cellData
                    }
                }
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
        var currentNodeCount = unsolvedCount()
        var previousNodeCount = 0

        repeat  {
            let isValid = isValidPuzzle()
            if !isValid {
                printDataSet(dataSet)
                assert( isValidPuzzle(), "Puzzle \(puzzleName) is not valid!" )
            }
            previousNodeCount = currentNodeCount

            if rows     {   prunePuzzleRows()    }
            if columns  {   prunePuzzleColumns() }
            if blocks   {   prunePuzzleBlocks()  }

            currentNodeCount = unsolvedCount()
            let isValid2 = isValidPuzzle()
            if !isValid2 {
                printDataSet(dataSet)
                assert( isValidPuzzle(), "Puzzle \(puzzleName) is not valid!" )
            }
        }
        while previousNodeCount != currentNodeCount
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

        for column in 0..<HLSolver.kColumns  {
            var cellData = dataSet.data[indexFor(row: row, column: column)]
            if cellData.data.count>1                            {
                cellData.data = cellData.data.subtracting(reduceSet)
                
                if !cellData.data.isEmpty  {
                    dataSet.data[indexFor(row: row, column: column)] = cellData
                }
            }
        }
    }
    
    //  check for cells that have only 1 value (ie .solved)
    func markSolvedCells() {
        for index in 0..<HLSolver.kCellCount {
            var cellData = dataSet.data[index]
            
            if cellData.data.count == 1 && cellData.status == .unsolvedStatus   {
                cellData.status = .solvedStatus
                dataSet.data[index] = cellData
            }
        }
    }
    
    func updateChangedCells()   {
        for index in 0..<HLSolver.kCellCount {
            var cellData = dataSet.data[index]
            let previousCellData = previousDataSet.data[index]
            
            //  first lets convert Changed to Solved or Unsollved
            if cellData.status == .changedStatus {
                if cellData.data.count == 1  {  cellData.status = .solvedStatus }
                else                         {   cellData.status = .unsolvedStatus }
                dataSet.data[index] = cellData
            }
            
            //  then find the cells that changed
            if puzzleState == .solving && cellData.data.count != previousCellData.data.count     {
                cellData.status = .changedStatus
                dataSet.data[index] = cellData
            }
        }
        
        markSolvedCells()
    }
    
    
    func nodeCount() -> Int {
        var count = 0
        for index in 0..<HLSolver.kCellCount {
            let cellData = dataSet.data[index]
            count += cellData.data.count     }
        
        return count - HLSolver.kCellCount
    }

    //  when count reaches zero set puzzleState to .final
    func unsolvedCount() -> Int
    {
        let count = nodeCount()
        if count == 0 {
            puzzleState = .final
        }
        return count
    }
    
    
    func solvedSetForRow(_ row: Int) -> Set<String>       {
        var solvedSet = Set<String>()
        for column in 0..<HLSolver.kColumns                      {
            let cellData = dataSet.data[indexFor(row: row, column: column)]
            if cellData.data.count == 1  {
                solvedSet = solvedSet.union(cellData.data)
            }
        }
        
        return solvedSet
    }


    func convertColumnsToRows() {
        let dataSetCopy = dataSet
        for row in 0..<HLSolver.kRows   {
            for column in 0..<HLSolver.kColumns {
                //  notice the row - column switch for dataSetCopy
                dataSet.data[indexFor(row: row, column: column)] = dataSetCopy.data[indexFor(row: column, column: row)]
            }
        }
    }
    
    
    func convertBlocksToRows() {
        let dataSetCopy = dataSet
        for row in 0..<HLSolver.kRows {
            let blockSet = blockIndexSet[row]
            for column2 in 0..<HLSolver.kRows {
                dataSet.data[indexFor(row: row, column: column2)] = dataSetCopy.data[blockSet[column2]]
            }
        }
    }


    func isValidPuzzle() -> Bool {
    
        func isValidPuzzleRow(_ row: Int) -> Bool {
            var returnValue = true
            var numArray = Array(repeating: 0, count: 10)
                
            for column in 0..<HLSolver.kColumns {
            
                let cellData = dataSet.data[indexFor(row: row, column: column)]
                let cell = Array(cellData.data)
                if cell.count == 1 {
                    let value = cell[0]
                    numArray[Int(value)!] += 1
                }
            }
            
            for i in 0..<numArray.count {
                if numArray[i] > 1 {
                    returnValue = false
                    break
                }
            }

            return returnValue
        }

        var returnValue = true
        for row in 0..<HLSolver.kRows {
            if !isValidPuzzleRow(row) {
                returnValue = false
                break
            }
        }
        
        return returnValue
    }


    func sectorForIndex(_ index: Int)->Int    {   return index/3  }
    
    
    func load(_ data: [String])
    {
        if data.count == HLSolver.kCellCount     {
            for i in 0..<HLSolver.kCellCount
            {
                let cellValue = data[i]
                var newCell = HLSudokuCell(data: HLSolver.fullSet, status: .unsolvedStatus)
                
                if ( cellValue != "0" )     {
                    newCell = HLSudokuCell(data: Set([data[i]]), status: .givenStatus)
                }
                
                dataSet.data[i] = newCell
            }
            
            previousDataSet = dataSet
        }
    }   
    
    func loadPuzzleWith(data: String)   {
        var array: [Substring] = data.split(separator: "\n")
        var tempData: [HLSudokuCell] = []
    //    var tempStatus = Array(repeating: 0, count: kCellCount)
        var tempName = ""
        tempName = String(array[0])
        array.remove(at: 0) //  get rid of the puzzlename line and leave cell data
        
        for index in 0..<HLSolver.kCellCount {
            let line = String(array[index])
            let valueArray = line.split(separator: "\t")
            let (valueInt, statusInt) = (Int(valueArray[0]), Int(valueArray[1]))

            //  make sure we get 2 Ints (value, status)
            guard let value = valueInt, let status = statusInt else {
                print("Bad data on line: \(index+1)   data: \(line)")
                return
            }
            
            //  make sure that status value is in range
            guard status >= 0,  status <= HLCellStatus.solvedStatus.rawValue else
            {
                print("Bad status data on line: \(index+1)   data: \(line)")
                return
            }
            
            if valueInt == 0   {
                tempData[index] = HLSudokuCell(data: HLSolver.fullSet, status: HLCellStatus.init(rawValue: status)!)
            }
            else    {
                let str = String(value)
                let data = Set<String>([str])
                tempData[index] = HLSudokuCell(data: data, status: .solvedStatus)
            }
        }
        dataSet.data = tempData
        prunePuzzle(rows:true, columns:true, blocks:true)
        
        guard isValidPuzzle() else  {
            print("Error:  Data was parsed but produced invalid puzzle.")
            return
        }
        
        previousDataSet = dataSet
        puzzleName = tempName
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
        for row in 0..<HLSolver.kRows    {  printRowDataSet(dataSet, row: row)    }
        print("\n")
    }

    required init(coder aDecoder: NSCoder)
    {
        let puzzleName  = aDecoder.decodeObject(forKey: kNameKey) as! String
        let dataSet   = aDecoder.decodeObject(forKey: kDataKey) as! HLDataSet
        
        self.dataSet = dataSet
        previousDataSet = dataSet
        self.puzzleName = puzzleName
        print("puzzleName: \(String(describing: puzzleName))")
    }
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.puzzleName, forKey: .puzzleName)
        try container.encode(self.puzzleState, forKey: .puzzleState)
        try container.encode(self.dataSet.data, forKey: .puzzleDataSet)
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        puzzleName = try values.decode(String.self, forKey: .puzzleName)
        puzzleState = try values.decode(HLPuzzleState.self, forKey: .puzzleState)
        dataSet.data = try values.decode([HLSudokuCell].self, forKey: .puzzleDataSet)
    }


    init() {
        print("HLSolver-  init")
        dataSet = HLDataSet()
        previousDataSet = dataSet
    }

    init(_ dataSet: HLDataSet) {
        print("HLSolver-  initWithDataSet")
        self.dataSet = dataSet
        previousDataSet = dataSet
    }

    init(html: String) {
        print("HLSolver-  init(html: String)")
        var puzzleString = html
        var puzzleArray = Array(repeating: "0", count: 81)
        
        dataSet = HLDataSet()
        previousDataSet = dataSet
        
        if let range: Range<String.Index> = puzzleString.range(of:"<form")  {
            puzzleString = String(puzzleString[range.lowerBound...])
  //          print( "*******************puzzleString: \(puzzleString)" )
            
            for index in 0..<81 {
                if let range: Range<String.Index> = puzzleString.range(of:"</td>")  {
                    let preString = puzzleString[puzzleString.startIndex...range.upperBound]
       //             print( "*******************preString: \(preString)" )
                    puzzleString.removeFirst(preString.count)
                    
                    if let range: Range<String.Index> = preString.range(of:"value=\"")  {
                        puzzleArray[index] = String(preString[range.upperBound])
                    }
                }
            }
            
    //        print( "puzzleString: \(puzzleString)" )
            if let range: Range<String.Index> = puzzleString.range(of:"Copy link for this puzzle\">")  {
                puzzleString = String(puzzleString[range.upperBound..<puzzleString.endIndex])
                if let range2: Range<String.Index> = puzzleString.range(of:"</a>")  {
                    puzzleName = String(puzzleString[puzzleString.startIndex..<range2.lowerBound])
                    load(puzzleArray)
        
                    previousDataSet = dataSet
                }
           }
        }
    }
    
    deinit {
        print("HLSolver-  deinit")
    }
}
