//
//  ColorChartView.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 5/4/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import SwiftUI

struct ColorChartView: View {
    let colorTable: [Color]
    var body: some View {
        HStack {
            ColorBox(title: "Given", color: colorTable[0])
            ColorBox(title: "Unsolved", color: colorTable[1])
            ColorBox(title: "Changed", color: colorTable[2])
            ColorBox(title: "Solved", color: colorTable[3])
        }
            .frame(width: 330, height: 60, alignment: .center)
            .padding(.top, 2)
            .border(Color.gray)
            .background(Color(red: 0.9, green: 0.9, blue: 0.9))
    }
}

struct ColorBox: View {
    let title: String
    let color: Color
    var body: some View {
         VStack {
            Rectangle()
                .fill(color)
                .border(Color.gray)
                .frame(width: 40, height: 15, alignment: .center)
                .padding(.horizontal)
            Text(title)
        }
    }
}

struct ColorChartView_Previews: PreviewProvider {
    static var previews: some View {
        ColorChartView(colorTable: [Color.green, Color.purple, Color.orange, Color.blue])
    }
}
