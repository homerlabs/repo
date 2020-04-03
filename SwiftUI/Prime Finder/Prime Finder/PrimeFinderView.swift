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
    @State private var showErrorFindPrimes: Bool = false
    @State private var showErrorFindNicePrimes: Bool = false
    let HLSavePanelTitle = "Prime Finder Save Panel"
    let terminalPrimeWidth: CGFloat = 100.0
    let startingMessage = "Starting ..."

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
                Button(pfViewModel.findPrimesInProgress ? "  Running  " : " Find Primes ", action: {
                    let success = self.pfViewModel.findPrimes()
                    self.pfViewModel.status = self.startingMessage
                   if !success {
                        self.pfViewModel.primesURL = nil
                        self.showErrorFindPrimes = true
                    }
                })
                .alert(isPresented: $showErrorFindPrimes) {
                    Alert(title: Text("Prime Finder Encountered Serious Error!"), message: Text("Bad Prime File Path."))}
                .disabled(pfViewModel.primesURL == nil || pfViewModel.findNPrimesInProgress)

                //  FindNPrimes Button
                Button(pfViewModel.findNPrimesInProgress ? "  Running  " : "Find NPrimes", action: {
                    let success = self.pfViewModel.findNPrimes()
                    self.pfViewModel.status = self.startingMessage
                    if !success {
                        self.pfViewModel.primesURL = nil
                        self.showErrorFindNicePrimes = true
                    }
                })
                .alert(isPresented: $showErrorFindNicePrimes) {
                    Alert(title: Text("Prime Finder Encountered Serious Error!"), message: Text("Bad Prime File Path."))}
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
