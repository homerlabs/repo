//
//  ContentView.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 3/23/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import SwiftUI

struct HLPuzzleView: View {

 //   let offlineManager = HLOfflineManager()
    @ObservedObject var puzzleViewModel = HLPuzzleViewModel()
    let mainPaddingX: CGFloat = 30
    let mainPaddingY: CGFloat = 15
    let windowBackgroundColor = Color(red: 0.85, green: 0.89, blue: 0.91)

    var body: some View {
        VStack() {
            TopSectionView(puzzleViewModel: puzzleViewModel)
            Spacer()
            HLGridView(puzzleViewModel: puzzleViewModel)
            Spacer()
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
