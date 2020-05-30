//
//  PrimeFinderView.swift
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
    @State private var showErrorInvalidData: Bool = false
    let HLSavePanelTitle = "Prime Finder Save Panel"
    let terminalPrimeWidth: CGFloat = 100.0
    let outsidePaddingValue: CGFloat = 16
    let verticalPaddingValue: CGFloat = 12
    let textFieldBackgroundColor = Color(red: 0.9, green: 0.9, blue: 0.9)
    let windowBackgroundColor = Color(red: 0.85, green: 0.89, blue: 0.91)

    var body: some View {
        
        VStack {
            Form {
                //**********  primes url
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
                        .background(textFieldBackgroundColor)

                    } else {
                        Text("Primes file path not set")
                        .background(textFieldBackgroundColor)
                    }
                }
                            
                //**********  nice primes url
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
                        .background(textFieldBackgroundColor)
                    } else {
                        Text("Nice Primes file path not set")
                        .background(textFieldBackgroundColor)
                    }
                }

                //**********  terminal prime
                HStack {
                    Text("Terminal Prime: ")
                    TextField(String(pfViewModel.terminalPrime), value: $pfViewModel.terminalPrime, formatter: NumberFormatter(), onCommit: {
                        if self.pfViewModel.terminalPrime == 0 {
                            self.showErrorInvalidData = true
                        }
                  })
                        .frame(width: terminalPrimeWidth)
                    Spacer()
                 
                    Text("Percent completed: \(pfViewModel.progress)")
               }
              .alert(isPresented: $showErrorInvalidData) {
                    Alert(title: Text("Invalid data in TextField"), message: Text("'Terminal Prime' value must be a non-zero integer"))}
                .padding(.top, verticalPaddingValue)
            }

            //**********  Status
            HStack {
                Text("Status: ")
                Text(pfViewModel.status)
                Spacer()
            }
            .padding(.bottom, verticalPaddingValue)
        
            VStack {
                //**********  FindPrimes Button
                Button(pfViewModel.findPrimesInProgress ? "   Running   " : " Find Primes ", action: {
                    if self.pfViewModel.findPrimesInProgress {
                        self.pfViewModel.stopProcess()
                    } else {
                        switch self.pfViewModel.findPrimes() {
                            
                            case .invalidDataError:
                                self.showErrorInvalidData = true
                            
                            case .badFilePathError:
                                self.pfViewModel.primesURL = nil
                                self.showErrorFindPrimes = true
                            
                            case .noError:
                                break
                        }
                    }
                })
                .alert(isPresented: $showErrorFindPrimes) {
                    Alert(title: Text("Prime Finder Encountered a Serious Error!"), message: Text("Primes file not found."))}
                .disabled(pfViewModel.primesURL == nil || pfViewModel.findNPrimesInProgress)

                //**********  FindNPrimes Button
                Button(pfViewModel.findNPrimesInProgress ? "   Running   " : "Find NPrimes", action: {
                    if self.pfViewModel.findNPrimesInProgress {
                        self.pfViewModel.stopProcess()
                    } else {
                        if self.pfViewModel.findNPrimes() != .noError {
                            self.pfViewModel.primesURL = nil
                            self.showErrorFindNicePrimes = true
                        }
                    }
                })
                .alert(isPresented: $showErrorFindNicePrimes) {
                    Alert(title: Text("Prime Finder Encountered a Serious Error!"), message: Text("Primes file not found."))}
                .disabled(pfViewModel.primesURL == nil || pfViewModel.nicePrimesURL == nil || pfViewModel.findPrimesInProgress)
            }
        }
    //    .frame(width: 500, height: 200, alignment: .center)
        .padding(outsidePaddingValue)
        .background(windowBackgroundColor)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PrimeFinderView()
    }
}
