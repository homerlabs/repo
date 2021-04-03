//
//  HLGridView.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 3/28/21.
//  Copyright © 2021 Matthew Homer. All rights reserved.
//

import SwiftUI

struct HLGridView: View {
    @ObservedObject var puzzleViewModel: HLPuzzleViewModel
    let cellSizeW: CGFloat = 75
    let cellSizeH: CGFloat = 80
    let cellTextColor = [Color.green, Color.purple, Color.orange, Color.blue]
    var cellColumns: [GridItem] = Array(repeating: GridItem(.fixed(80)), count: 9)

    var body: some View {
        ZStack {
        LazyVGrid(columns: cellColumns) {
            ForEach(puzzleViewModel.solver.dataSet.indices) { index in
                let cell = puzzleViewModel.solver.dataSet[index]
                Text("\(cell.setToString())")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 5)
                    .font(.subheadline)
                    .foregroundColor(self.cellTextColor[cell.status.rawValue])
                    .background(Color.init(red: 0.95, green: 0.85, blue: 0.85))
                    .frame(minWidth: cellSizeW, idealWidth: cellSizeW, maxWidth: cellSizeW, minHeight: cellSizeH, idealHeight: cellSizeH, maxHeight: cellSizeH, alignment: .center)
            }
        }
            OverlayView(width: 250, height: 245).opacity(0.1)
        }
    }
}

struct HLGridView_Previews: PreviewProvider {
    static var previews: some View {
        HLGridView(puzzleViewModel: HLPuzzleViewModel())
    }
}
