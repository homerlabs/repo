//
//  LoadSaveView.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 10/28/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import SwiftUI

struct LoadSaveView: View {
    @ObservedObject var puzzleViewModel: HLPuzzleViewModel

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Button(action: {
                    puzzleViewModel.solver.saveDataToUserDefaults(puzzleViewModel.solver.dataSet)
                    puzzleViewModel.solver.saveDataToDocuments(puzzleViewModel.solver.dataSet)
                }) {
                    Text("Save")
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    puzzleViewModel.solver.fastSolve()
                }) {
                    Text("FSolve")
                }
                .padding(.vertical, 10)
                
                Button(action: {
                    if let solver = puzzleViewModel.solver.loadData() {
                        puzzleViewModel.solver = solver
                    }
                }) {
                    Text("Load")
                }
            }
            Spacer()
        }
    }
    
}

struct LoadSaveView_Previews: PreviewProvider {
    static var previews: some View {
        LoadSaveView(puzzleViewModel: HLPuzzleViewModel())
    }
}
