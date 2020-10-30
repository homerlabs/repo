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
                    puzzleViewModel.solver.save()
                }) {
                    Text("Save")
                }
                .padding(.bottom)
                
                Button(action: {
                    puzzleViewModel.solver.read()
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
