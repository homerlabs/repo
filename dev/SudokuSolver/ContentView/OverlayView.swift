//
//  OverlayView.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 5/7/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import SwiftUI

struct OverlayView: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        VStack {
            SimpleThreeBoxes(width: width, height: height)
            SimpleThreeBoxes(width: width, height: height)
            SimpleThreeBoxes(width: width, height: height)
        }
    }
}

struct SimpleBox: View {
    @State var width: CGFloat
    @State var height: CGFloat
    var body: some View {
                Rectangle()
                .fill(Color.gray)
                .border(Color.gray)
                .frame(width: width, height: height, alignment: .center)
    }
}

struct SimpleThreeBoxes: View {
    @State var width: CGFloat
    @State var height: CGFloat
    var body: some View {
        HStack {
            SimpleBox(width: width, height: height)
            SimpleBox(width: width, height: height)
            SimpleBox(width: width, height: height)
        }
    }
}

struct OverlayView_Previews: PreviewProvider {
    static var previews: some View {
        OverlayView(width: 50, height: 50)
    }
}
