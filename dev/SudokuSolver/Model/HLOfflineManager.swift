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

struct HLPuzzleOfflineDataSet: Codable {
    let data: [HLPuzzleRaw]
}

class HLOfflineManager: NSObject {
    var puzzleStore: [HLPuzzleRaw] = []
    let hlKeyPuzzleCountLimit = "hlKeyPuzzleCountLimit"
    let hlKeyPuzzleData = "hlKeyPuzzleData"
    let puzzleCountLimitDefault = 3
    var puzzleCountLimit = 0

    public func insertPuzzle(data: [Int], name: String) {
        print("insertPuzzle  name: \(name)")
        
        if puzzleStore.count < puzzleCountLimit {
            let puzzle = HLPuzzleRaw(data: data, name: name)
            puzzleStore.append(puzzle)
            
            saveSetting()
        }
    }
    
    public func fetchRandomPuzzle() -> HLPuzzleRaw? {
        print("fetchRandomPuzzle  pusszleStore: \(String(describing: puzzleStore.count))")
        return nil
    }
    
    func saveSetting() {
        print("HLOfflineManager-  saveSetting")
        print("HLOfflineManager saveSetting-  pusszleStore: \(puzzleStore)")
        UserDefaults.standard.set(puzzleCountLimit, forKey: hlKeyPuzzleCountLimit)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(HLPuzzleOfflineDataSet(data: puzzleStore))
            UserDefaults.standard.set(data, forKey: hlKeyPuzzleData)
        } catch {
            print("Unable to Encode puzzleDataset (\(error))")
        }
    }
    
    override init() {
        puzzleCountLimit = UserDefaults.standard.integer(forKey: hlKeyPuzzleCountLimit)
        if puzzleCountLimit == 0 {
            puzzleCountLimit = puzzleCountLimitDefault
        }
        
        if let data = UserDefaults.standard.data(forKey: hlKeyPuzzleData) {
            do {
                let decoder = JSONDecoder()
                let offlineDataset = try decoder.decode(HLPuzzleOfflineDataSet.self, from: data)
                puzzleStore = offlineDataset.data
                
            } catch {
                print("Unable to Decode offlineDataset (\(error))")
            }
        }
        print("HLOfflineManager init-  pusszleStore: \(puzzleStore)")
    }
}
