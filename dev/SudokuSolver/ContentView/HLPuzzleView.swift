//
//  ContentView.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 3/23/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import SwiftUI

struct HLPuzzleView: View {

    @ObservedObject var puzzleViewModel = HLPuzzleViewModel()
    let hlCellSize: CGFloat = 40
    let mainPaddingX: CGFloat = 45
    let mainPaddingY: CGFloat = 20
    let undoSolvePadding: CGFloat = 25
    let cellTextColor = [Color.green, Color.purple, Color.orange, Color.blue]
    let windowBackgroundColor = Color(red: 0.85, green: 0.89, blue: 0.91)
    let numberOfColumns = 9
    @State private var aboutPanelPresented = false

    var body: some View {
        ZStack(alignment: .center) {
            VStack {
                HStack(alignment: .top) {
                    //*****  Rows, Columns, and Blocks Switches
                    ButtonsView(testRows: puzzleViewModel.testRows, testColumns: puzzleViewModel.testColumns, testBlocks: puzzleViewModel.testBlocks, algorithmSelected: puzzleViewModel.algorithmSelected)
                    Spacer()

                    //*****  Color Chart, puzzle name, and Node Count
                    VStack(alignment: .trailing) {
                        ColorChartView(colorTable: cellTextColor)
                        Text(puzzleViewModel.solver.puzzleName).padding(.top, 5)

                        Text("Unsolved Nodes: \(puzzleViewModel.unsolvedNodeCount)").padding(.top, 3)
                    }
                }
                .padding(.horizontal, mainPaddingX)
                .padding(.top, mainPaddingY)

                Spacer()
               //*****  Algorithm Picker
                Picker(selection: $puzzleViewModel.algorithmSelected, label: Text("Not Used")) {
                    Text("Mono Cell").tag(HLAlgorithmMode.monoCell)
                    Text("Find Sets").tag(HLAlgorithmMode.findSets)
                    Text("Mono Sector").tag(HLAlgorithmMode.monoSector)
                }.pickerStyle(SegmentedPickerStyle())
                 .padding(.horizontal, mainPaddingX)
                 .padding(.bottom, 15)

                //*****  Undo and Solve/Prune buttons
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

                //*****  New Puzzle button and About button
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
                    .padding(.bottom, mainPaddingY)
                    .padding(.horizontal, mainPaddingX)
           }
            .sheet(isPresented: $aboutPanelPresented, onDismiss: {
                    print("$aboutPanelPresented: \(self.aboutPanelPresented)")
                }) {
                    AboutView()
                }

            //*****  9 x 9 grid
            HLGridView(columns: numberOfColumns, items: puzzleViewModel.solver.dataSet.grid) { item in
                VStack {
                    Text(self.setToString(item.0))
                        .font(.subheadline)
                        .foregroundColor(self.cellTextColor[item.1.rawValue])
                }
                    .background(Color.init(red: 0.95, green: 0.85, blue: 0.85))
            }
            .frame(width: 780, height: 780, alignment: .center)
           
            OverlayView().opacity(0.1)
        }
            .background(windowBackgroundColor)
    }
    
    func setToString(_ aSet: Set<String>)->String     {
        let list = Array(aSet.sorted(by: <))
        
        if list.count == 0 {
            return "123456789"
        }
        else   {
            var returnString = ""
            for index in 0..<list.count     {   returnString += list[index]     }
            return returnString
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HLPuzzleView()
           .previewLayout(.fixed(width: 800, height: 1100))
    }
}
