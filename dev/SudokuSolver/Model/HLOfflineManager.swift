//
//  HLOfflineManager.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 5/19/23.
//  Copyright © 2023 Matthew Homer. All rights reserved.
//

import Foundation

struct HLPuzzleRaw: Codable {
    let data: [Int]
    let name: String
}

class HLOfflineManager {
    var pusszleStore: [HLPuzzleRaw]?
    let hlKeyPuzzleCount = "hlKeyPuzzleCount"
    var puzzleCount = 0

    public func insertPuzzle(data: [Int], name: String) {
        print("insertPuzzle  name: \(name)")
    }
    
    public func fetchRandomPuzzle() -> HLPuzzleRaw? {
        print("fetchRandomPuzzle  pusszleStore: \(String(describing: pusszleStore?.count))")
        return nil
    }
}
