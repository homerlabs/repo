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
        ZStack(alignment: .center) {
            //*****  9 x 9 grid
            HLGridView(columns: numberOfColumns, items: puzzleViewModel.solver.dataSet.grid) { item in
                VStack {
                    Text(self.setToString(item.0))
                        .font(.subheadline)
                        .foregroundColor(self.cellTextColor[item.1.rawValue])
                }
                .background(Color.init(red: 0.95, green: 0.85, blue: 0.85))
                .padding(.top, 15)
           }
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

struct MiddleSectionView_Previews: PreviewProvider {
    static var previews: some View {
        MiddleSectionView(puzzleViewModel: HLPuzzleViewModel())
    }
}
