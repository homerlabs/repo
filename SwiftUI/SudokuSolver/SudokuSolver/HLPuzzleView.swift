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
    let hlToggleSize: CGFloat = 150
    let mainPadding: CGFloat = 40
    let textColor = [Color.orange, Color.blue, Color.red, Color.green]
    let windowBackgroundColor = Color(red: 0.85, green: 0.89, blue: 0.91)
    let numberOfColumns = 9

    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                HStack() {
                    //*****  Rows, Columns, and Blocks Switches
                    VStack {
                        HStack {
                           Toggle(isOn: $puzzleViewModel.testRows, label:  {
                                Text("Rows")
                            })
                            .frame(width: hlToggleSize)
                            Spacer()
                        }
                        HStack {
                            Toggle(isOn: $puzzleViewModel.testColumns) {
                                Text("Columns")
                            }
                            .frame(width: hlToggleSize)
                            Spacer()
                        }
                            
                       HStack {
                            Toggle(isOn: $puzzleViewModel.testBlocks) {
                                Text("Blocks")
                            }
                            .frame(width: hlToggleSize)
                            Spacer()
                        }
                    }
                    Spacer()
                    
                    //*****  Color Chart and Node Count
                    VStack(alignment: .trailing) {
                        ColorChartView()
                        Text("Unsolved Nodes: \(puzzleViewModel.unsolvedNodeCount)")
                            .padding(.vertical)
                    }
                }
                .padding(mainPadding)
                
                //*****  9 x 9 grid
                HLGridView(columns: numberOfColumns, items: puzzleViewModel.solver.dataSet.grid) { item in
                    VStack {
                        Text(self.setToString(item.0))
                            .font(.subheadline)
                            .foregroundColor(self.textColor[item.1.rawValue])
                    }
                        .background(Color.init(red: 0.9, green: 0.9, blue: 0.9))
                }
                
                //*****  Algorithm Picker
                Picker(selection: $puzzleViewModel.algorithmSelected, label: Text("Not Used")) {
                    Text("Mono Cell").tag(HLAlgorithmMode.monoCell)
                    Text("Find Sets").tag(HLAlgorithmMode.findSets)
                    Text("Mono Sector").tag(HLAlgorithmMode.monoSector)
                }.pickerStyle(SegmentedPickerStyle())
                .padding(mainPadding)

                //*****  Undo and Solve/Prune buttons
                HStack {
                    Spacer()
                    Button(action: {
                        print("Undo Button")
                  //      self.puzzleViewModel.solveAction()
                    }) {
                        Text("Undo").padding()
                    }
                    
                    Button(action: {
                        print("Solve Button")
                        self.puzzleViewModel.solveAction()
                    }) {
                        puzzleViewModel.puzzleState == HLPuzzleState.initial ? Text("Prune").padding(.trailing, 40) : Text("Solve").padding()
                    }
                    Spacer()
               }

                //*****  New Puzzle button, Puzzle Name Label, and About button
                HStack {
                    Button(action: {
                        print("New Puzzle Button")
                        self.puzzleViewModel.getNewPuzzle()
                    }) {
                        Text("New Puzzle")
                            .padding()
                    }
                    
                    Spacer()
                    Text(puzzleViewModel.solver.puzzleName)
                        .padding()
                    Spacer()
                    
                    Button(action: {
                        print("About Button")
                //        self.puzzleViewModel.solveAction()
                    }) {
                        Text("About").padding()
                    }
                }
                 .padding(mainPadding)
           }
            .background(windowBackgroundColor)
            
            OverlayView().opacity(0.1)
        }
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
    }
}
