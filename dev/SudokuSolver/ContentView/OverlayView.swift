//
//  OverlayView.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 5/7/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import SwiftUI

let paddingSize: CGFloat = 5

struct OverlayView: View {
    let width: CGFloat
    let height: CGFloat
    let paddingSize: CGFloat = 5
    var body: some View {
        VStack {
        Spacer()
        SimpleThreeBoxes(width: width, height: height)
        SimpleThreeBoxes(width: width, height: height)
            .padding(.vertical, paddingSize)
        SimpleThreeBoxes(width: width, height: height)
        Spacer()
        }
    }
}

struct SimpleBox: View {
    let width: CGFloat
    let height: CGFloat
    var body: some View {
        Rectangle()
        .fill(Color.gray)
        .border(Color.gray)
        .frame(width: width, height: height, alignment: .center)
    }
}

struct SimpleThreeBoxes: View {
    let width: CGFloat
    let height: CGFloat
    var body: some View {
        HStack {
            Spacer()
            SimpleBox(width: width, height: height)
            SimpleBox(width: width, height: height)
                .padding(.horizontal, paddingSize)
            SimpleBox(width: width, height: height)
            Spacer()
        }
    }
}

struct OverlayView_Previews: PreviewProvider {
    static var previews: some View {
        OverlayView(width: 100, height: 100)
    }
}
