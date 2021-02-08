//
//  BottomSectionView.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 10/15/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import SwiftUI

struct BottomSectionView: View {
    @ObservedObject var puzzleViewModel: HLPuzzleViewModel
    @State private var aboutPanelPresented = false
    let undoSolvePadding: CGFloat = 25

    var body: some View {
        VStack {
           //*****  Algorithm Picker
             Picker(selection: $puzzleViewModel.algorithmSelected, label: Text("Not Used")) {
                 Text("Mono Cell").tag(HLAlgorithmMode.monoCell)
                 Text("Find Sets").tag(HLAlgorithmMode.findSets)
                 Text("Mono Sector").tag(HLAlgorithmMode.monoSector)
             }.pickerStyle(SegmentedPickerStyle())
              .padding(.vertical, 15)

            HStack {
                Spacer()
                Button(action: {
                    print("Undo Button")
                    self.puzzleViewModel.undoAction()
                }) {
                    Text("Undo")
                        .padding(.horizontal, undoSolvePadding)
                }
                    .disabled(!self.puzzleViewModel.undoButtonEnabled)
                
                Button(action: {
                    print("Solve Button")
                    self.puzzleViewModel.solveAction()
                }) {
                    puzzleViewModel.solver.puzzleState == .initial ?
                        Text("Prune").padding(.horizontal, undoSolvePadding) :
                        Text("Solve").padding(.horizontal, undoSolvePadding)
                }
                    .disabled(self.puzzleViewModel.solver.puzzleState == .final)
                Spacer()
            }
 
            HStack {
                 Button(action: {
                    print("New Puzzle Button")
                    self.puzzleViewModel.getNewPuzzle()
                }) {
                    Text("New Puzzle")
                }
                
                Spacer()
                
                Button(action: {
                    print("About Button")
                    self.aboutPanelPresented.toggle()
                }) {
                    Text("About").padding()
                }
            }
            .sheet(isPresented: $aboutPanelPresented, onDismiss: {
                print("$aboutPanelPresented: \(self.aboutPanelPresented)")
            }) {
                AboutView()
            }

        }
    }
}

struct BottomSectionView_Previews: PreviewProvider {
    static var previews: some View {
        BottomSectionView(puzzleViewModel: HLPuzzleViewModel())
    }
}
