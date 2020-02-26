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

    var body: some View {
        
        VStack {
            Form {
                Spacer()

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
                        Text("Prime file path not set")
                    }
                    Spacer()
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
                        Text("Nice Prime file path not set")
                    }

                    Spacer()
                }

                //  terminal prime
                HStack {
                    Text("Terminal Prime: ")
                    TextField(pfViewModel.terminalPrime, text: $pfViewModel.terminalPrime)
                    Spacer()
                }
            }
            
            //  Status
            HStack {
                Text("Status: ")
                Text(pfViewModel.status)
                Spacer()
            }
        
            //  FindPrimes Button
            Button(action: {
                print("Find primes Button clicked")
                self.pfViewModel.findPrimes()
            }) {
                if pfViewModel.findPrimesInProgress {
                    Text("Running ")
                } else {
                    Text("Find Primes")
                }
            }
            .disabled(pfViewModel.primesURL == nil || pfViewModel.findNPrimesInProgress)

            //  FindNPrimes Button
            Button(action: {
                print("Find nice primes Button clicked")
                self.pfViewModel.findNPrimes()
            }) {
                if pfViewModel.findNPrimesInProgress {
                     Text("Running ")
                 } else {
                     Text("Find NPrimes")
                 }
            }
            .disabled(pfViewModel.primesURL == nil || pfViewModel.nicePrimesURL == nil || pfViewModel.findPrimesInProgress)

            Spacer()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PrimeFinderView()
    }
}
