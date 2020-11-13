//
//  TopSectionView.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 10/15/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import SwiftUI

struct TopSectionView: View {
    @ObservedObject var puzzleViewModel: HLPuzzleViewModel
    let switchPadding: CGFloat = 5
    let hlToggleSize: CGFloat = 150
    let cellTextColorTable = [Color.green, Color.purple, Color.orange, Color.blue]

    var body: some View {
        HStack(alignment: .center) {
            //*****  Rows, Columns, and Blocks Switches
            VStack {
                HStack {
                    Toggle(isOn: $puzzleViewModel.testRows, label:  {
                        Text("Rows")
                    }).frame(width: hlToggleSize)
                    Spacer()
                }
                .padding(.bottom, switchPadding)

                HStack {
                    Toggle(isOn: $puzzleViewModel.testColumns) {
                        Text("Columns")
                    }.frame(width: hlToggleSize)
                    Spacer()
                }
                .padding(.bottom, switchPadding)

                HStack {
                    Toggle(isOn: $puzzleViewModel.testBlocks) {
                        Text("Blocks")
                    }.frame(width: hlToggleSize)
                    .disabled(puzzleViewModel.algorithmSelected != .findSets)
                    Spacer()
                }
            }
            
            //  allows for saving and loading dataSets
            #if DEBUG
            LoadSaveView(puzzleViewModel: puzzleViewModel)
            #endif

            //*****  Color Chart, puzzle name, and Node Count
            VStack(alignment: .trailing) {
                ColorChartView(colorTable: cellTextColorTable)
                Text(puzzleViewModel.solver.puzzleName).padding(.top, 5)
                Text("Unsolved Nodes: \(puzzleViewModel.unsolvedNodeCount)").padding(.top, 3)
            }
        }
    }
}

struct TopSectionView_Previews: PreviewProvider {
    static var previews: some View {
        TopSectionView(puzzleViewModel: HLPuzzleViewModel())
    }
}
