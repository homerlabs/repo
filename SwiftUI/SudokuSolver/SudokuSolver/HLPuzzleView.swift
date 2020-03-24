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

    var body: some View {
        VStack {
            List() {
                Spacer()
                ForEach(0..<9) { indexI in
                    HStack {
                    Spacer()
                    ForEach(0..<9) { indexJ in
                        Text(self.setToString(self.puzzleViewModel.data[indexI*9+indexJ]))
                        .padding()
                        .background(Color.yellow)
                    }
                    Spacer()
                }
            }
      //      Spacer()
        }
        Text("JJ")
        Spacer()
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
