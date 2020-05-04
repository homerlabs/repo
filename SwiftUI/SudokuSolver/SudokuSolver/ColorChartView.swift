//
//  ColorChartView.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 5/4/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import SwiftUI

struct ColorChartView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
                .border(Color.gray)
                .frame(width: 330, height: 60, alignment: .center)
            HStack {
                ColorBox(title: "Given", color: Color.yellow)
                ColorBox(title: "Unsolved", color: Color.blue)
                ColorBox(title: "Changed", color: Color.red)
                ColorBox(title: "Solved", color: Color.green)
            }
        }
            .background(Color(red: 0.9, green: 0.9, blue: 0.9))
    }
}

struct ColorBox: View {
    @State var title: String
    @State var color: Color
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
        ColorChartView()
    }
}
