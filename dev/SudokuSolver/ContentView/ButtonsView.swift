//
//  ButtonsView.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 9/28/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import SwiftUI

struct ButtonsView: View {
    let switchPadding: CGFloat = 5
    let mainPadding: CGFloat = 35
    let hlToggleSize: CGFloat = 150
    @State var testRows: Bool
    @State var testColumns: Bool
    @State var testBlocks: Bool
    var algorithmSelected: HLAlgorithmMode

    var body: some View {
        VStack {
            HStack {
               Toggle(isOn: $testRows, label:  {
                    Text("Rows")
                })
                .frame(width: hlToggleSize)
                Spacer()
            }
            .padding(.bottom, switchPadding)
            
            HStack {
                Toggle(isOn: $testColumns) {
                    Text("Columns")
                }
                .frame(width: hlToggleSize)
                Spacer()
            }
            .padding(.bottom, switchPadding)
            
          HStack {
                Toggle(isOn: $testBlocks) {
                    Text("Blocks")
                }
                .disabled(algorithmSelected != .findSets)
                .frame(width: hlToggleSize)
                Spacer()
            }
        }
    }
}

struct ButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonsView(testRows: true, testColumns: true, testBlocks: true, algorithmSelected: HLAlgorithmMode.findSets)
    }
}
