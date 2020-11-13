//
//  MiddleSectionView.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 10/15/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import SwiftUI

struct MiddleSectionView: View {
    @ObservedObject var puzzleViewModel: HLPuzzleViewModel
    let numberOfColumns = 9
    let cellTextColor = [Color.green, Color.purple, Color.orange, Color.blue]

    var body: some View {
        //*****  9 x 9 grid
        GridView(columns: numberOfColumns, items: puzzleViewModel.solver.dataSet) { item in
            Text(item.setToString())
                .font(.subheadline)
                .foregroundColor(self.cellTextColor[item.status.rawValue])
                .background(Color.init(red: 0.95, green: 0.85, blue: 0.85))
        }
    }
}

struct MiddleSectionView_Previews: PreviewProvider {
    static var previews: some View {
        MiddleSectionView(puzzleViewModel: HLPuzzleViewModel())
    }
}
