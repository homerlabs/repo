//
//  HLPuzzleViewModel.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 3/24/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import Foundation

class HLPuzzleViewModel: ObservableObject {
    @Published var data: [Set<String>] = Array(repeating: ["1", "2"], count: 81)
}

