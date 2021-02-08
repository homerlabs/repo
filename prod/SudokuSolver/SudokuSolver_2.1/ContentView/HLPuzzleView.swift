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
    let mainPaddingX: CGFloat = 30
    let mainPaddingY: CGFloat = 20
    let windowBackgroundColor = Color(red: 0.85, green: 0.89, blue: 0.91)

    var body: some View {
        VStack() {
            TopSectionView(puzzleViewModel: puzzleViewModel)
            MiddleSectionView(puzzleViewModel: puzzleViewModel)
            BottomSectionView(puzzleViewModel: puzzleViewModel)
        }
        .padding(.vertical, mainPaddingY)
        .padding(.horizontal, mainPaddingX)
        .background(windowBackgroundColor)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HLPuzzleView()
    }
}
