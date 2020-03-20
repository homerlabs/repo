//
//  ContentView.swift
//  Prime Finder
//
//  Created by Matthew Homer on 2/20/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import SwiftUI

struct PrimeFinderView: View {

    @ObservedObject var pfViewModel = PrimeFinderViewModel()
    let HLSavePanelTitle = "Prime Finder Save Panel"
    let terminalPrimeWidth: CGFloat = 100.0
    let startMessage = "Creating PTable"

    var body: some View {
        
        VStack {
            Form {
                //  prime url
                HStack {
                    Button(action: {
                        print("Primes Button clicked")
                        let path = "Primes"
                        self.pfViewModel.primesURL = path.getSaveFilePath(title: self.HLSavePanelTitle, message: "Set Primes file path")
                    }) {
                        Text(" Set Primes ")
                    }

                    if pfViewModel.primesURL != nil {
                        Text(pfViewModel.primesURL!.path)

                    } else {
                        Text("Primes file path not set")
                    }
                }
                            
                //  nice prime url
                HStack {
                    Button(action: {
                        print("Nice primes Button clicked")
                        let path = "NicePrimes"
                        self.pfViewModel.nicePrimesURL = path.getSaveFilePath(title: self.HLSavePanelTitle, message: "Set NicePrimes file path")
                    }) {
                        Text("Set NPrimes")
                    }

                    if pfViewModel.nicePrimesURL != nil {
                        Text(pfViewModel.nicePrimesURL!.path)
                    } else {
                        Text("Nice Primes file path not set")
                    }
                }

                //  terminal prime
                HStack {
                    Text("Terminal Prime: ")
                    TextField(pfViewModel.terminalPrime, text: $pfViewModel.terminalPrime)
                        .frame(width: terminalPrimeWidth)
                    Spacer()
                }
                .padding(.vertical)
}
            .padding(.bottom)

            //  Status
            HStack {
                Text("Status: ")
                Text(pfViewModel.status)
                Spacer()
            }
        
            VStack {
                //  FindPrimes Button
                Button(action: {
                    self.pfViewModel.findPrimes()
                }) {
                    pfViewModel.findPrimesInProgress ? Text("Running ") : Text(" Find Primes ")
                }
                .disabled(pfViewModel.primesURL == nil || pfViewModel.findNPrimesInProgress)

                //  FindNPrimes Button
                Button(action: {
                    self.pfViewModel.findNPrimes()
                }) {
                    pfViewModel.findNPrimesInProgress ? Text("Running ") : Text("Find NPrimes")
                }
                .disabled(pfViewModel.primesURL == nil || pfViewModel.nicePrimesURL == nil || pfViewModel.findPrimesInProgress)
            }
        }
        .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PrimeFinderView()
    }
}
