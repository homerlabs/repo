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

    var body: some View {
        VStack {
                VStack {
                    HStack {
                       Toggle(isOn: $puzzleViewModel.testRows) {
                            Text("Rows")
                        }
                        Spacer()
                    }
                        Toggle(isOn: $puzzleViewModel.testColumns) {
                            Text("Columns")
                        //        .padding(.horizontal)
                        }
                        
                        Toggle(isOn: $puzzleViewModel.testBlocks) {
                            Text("Blocks")
                        }
         //       Spacer()
         //        Text("Help!!!")
           }
           
            VStack {
                ForEach(0..<9) { indexI in
                    HStack {
                //    Spacer()
                    ForEach(0..<9) { indexJ in
                        Text(self.setToString(self.puzzleViewModel.dataArray[indexI*9+indexJ]))
                            .frame(width: self.hlCellSize, height: self.hlCellSize, alignment: .center)
                            .padding()
                            .background(Color.yellow)
                    }
                        .padding(2)
                }
            }
      //      Spacer()
        }
                .padding()
                
            HStack {
                Button(action: {
                    print("New Puzzle Button")
                    self.puzzleViewModel.getNewPuzzle()
                }) {
                    Text("New Puzzle")
                        .padding()
                }
                
                Spacer()
                Text(puzzleViewModel.puzzleName)
                    .padding()
                Spacer()
                
                Button(action: {
                    print("Solve Button")
                    self.puzzleViewModel.solveAction()
                }) {
                    puzzleViewModel.puzzleState == HLPuzzleState.initial ? Text("Prune").padding() : Text("Solve").padding()
                }
            }
        }
    }
    
    func setToString(_ aSet: Set<String>)->String     {
        let list = Array(aSet.sorted(by: <))
        var returnString = ""
        if list.count < 9   {
            for index in 0..<list.count     {   returnString += list[index]     }
        }
        return returnString
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HLPuzzleView()
    }
}
