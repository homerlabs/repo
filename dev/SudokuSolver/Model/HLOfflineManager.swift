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

class HLOfflineManager: NSObject {
    var puzzleStore: [HLPuzzleRaw] = []
    let hlKeyPuzzleCountLimit = "hlKeyPuzzleCountLimit"
    let hlKeyPuzzleData = "hlKeyPuzzleData"
    var puzzleCountLimit = 3

    public func insertPuzzle(data: [Int], name: String) {
        print("insertPuzzle  name: \(name)")
        
        if puzzleStore.count < puzzleCountLimit {
            let puzzle = HLPuzzleRaw(data: data, name: name)
            puzzleStore.append(puzzle)
        }
    }
    
    public func fetchRandomPuzzle() -> HLPuzzleRaw? {
        print("fetchRandomPuzzle  pusszleStore: \(String(describing: puzzleStore.count))")
        return nil
    }
    
    override init() {
        print("HLOfflineManager-  init")
        puzzleCountLimit = UserDefaults.standard.integer(forKey: hlKeyPuzzleCountLimit)
        puzzleStore = UserDefaults.standard.object(forKey: hlKeyPuzzleData) as! [HLPuzzleRaw]
    }
    
    deinit {
        print("HLOfflineManager-  deinit")
        print("HLOfflineManager-  pusszleStore: \(puzzleStore)")
        UserDefaults.standard.set(puzzleCountLimit, forKey: hlKeyPuzzleCountLimit)
        UserDefaults.standard.set(puzzleStore, forKey: hlKeyPuzzleData)
    }
    
}
