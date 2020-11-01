//
//  LoadSaveView.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 10/28/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import SwiftUI

struct LoadSaveView: View {
    let kDataKey = "DataKey"
    @ObservedObject var puzzleViewModel: HLPuzzleViewModel

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Button(action: {
                    saveData()
                }) {
                    Text("Save")
                }
                .padding(.bottom)
                
                Button(action: {
                    loadData()
                }) {
                    Text("Load")
                }
            }
            Spacer()
        }
    }
    
    func saveData() {
        print( "LoadSaveView-  saveData" )
        let plistEncoder = PropertyListEncoder()
        if let data = try? plistEncoder.encode(puzzleViewModel.solver) {
            UserDefaults.standard.set(data, forKey: kDataKey)
        }
    }
    func loadData()  {
            print( "LoadSaveView-  loadData" )
            
        if let data = UserDefaults.standard.data(forKey: kDataKey)    {
                let plistDecoder = PropertyListDecoder()
                if let solver  = try? plistDecoder.decode(HLSolver.self, from:data) {
                    puzzleViewModel.solver = solver
                }
            }
        }
}

struct LoadSaveView_Previews: PreviewProvider {
    static var previews: some View {
        LoadSaveView(puzzleViewModel: HLPuzzleViewModel())
    }
}
