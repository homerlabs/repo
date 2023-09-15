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
    let numberOfProcessesWidth: CGFloat = 80.0
    let terminalPrimeWidth: CGFloat = 100.0
    let outsidePaddingValue: CGFloat = 16
    let verticalPaddingValue: CGFloat = 12
    let textFieldBackgroundColor = Color(red: 0.9, green: 0.9, blue: 0.9)
    let windowBackgroundColor = Color(red: 0.85, green: 0.89, blue: 0.91)
    let fileManager = HLFileManager.shared

    var body: some View {
        
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                //**********  primes url
                HStack {
                    Button(action: {
                        print("Primes Button clicked")
                        var filename = "Primes"
                        if let name = self.pfViewModel.primesURL?.lastPathComponent {
                            filename = name
                        }
                        self.pfViewModel.primesURL = self.fileManager.getURLForWritting(title: "Prime Finder Save Panel", message: "Set Primes file path", filename: filename)
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
                        var filename = "NicePrimes"
                        if let name = self.pfViewModel.nicePrimesURL?.lastPathComponent {
                            filename = name
                        }
                        self.pfViewModel.nicePrimesURL = self.fileManager.getURLForWritting(title: "Prime Finder Save Panel", message: "Set NicePrimes file path", filename: filename)
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
                        else {
                            UserDefaults.standard.set(pfViewModel.terminalPrime, forKey: HLPrime.HLTerminalPrimeKey)
                        }
                  })
                    .frame(width: terminalPrimeWidth)
                   
               }
              .alert(isPresented: $showErrorInvalidData) {
                    Alert(title: Text("Invalid data in TextField"), message: Text("'Terminal Prime' value must be a non-zero integer"))}
                .padding(.top, verticalPaddingValue)
                
                //**********  Status
                HStack {
                    Text("Status: ")
                    Text(pfViewModel.status)
                    Spacer()
                 
                    Text("Percent completed: \(pfViewModel.progress)")
                }
                .padding(.bottom, verticalPaddingValue)
            
                HStack {
                    Toggle(isOn: $pfViewModel.runInParallel) {
                        Text("Run in Parallel")
                    }
                    
                    if( pfViewModel.runInParallel ) {
                        Spacer()

                        Text("Number of Processes: ")
                        TextField(String(pfViewModel.processCount), value: $pfViewModel.processCount, formatter: NumberFormatter(), onCommit: {
                            if self.pfViewModel.terminalPrime == 0 {
                                self.showErrorInvalidData = true
                            }
                            else {
                                UserDefaults.standard.set(pfViewModel.processCount, forKey: HLPrime.HLNumberOfProcessesKey)
                            }
                        })
                        .frame(width: numberOfProcessesWidth)
                    }
                }
         //       Spacer()
            }
        }
        .padding(outsidePaddingValue)
        .background(windowBackgroundColor)

        Spacer()

        VStack(alignment: .center) {
            //**********  FindPrimes Button
            Button(pfViewModel.findPrimesInProgress ? "   Running   " : " Find Primes ", action: {
                if self.pfViewModel.findPrimesInProgress {
                    self.pfViewModel.stopProcess()
                } else {
                    switch self.pfViewModel.findPrimes() {
                        
                        case .invalidDataError:
                            self.showErrorInvalidData = true
                        
                        case .badPrimesFilePathError:
                            self.pfViewModel.primesURL = nil
                            self.showErrorFindPrimes = true
                        
                        case .badNicePrimesFilePathError, .noError:
                            break
                    }
                }
            })
            .alert(isPresented: $showErrorFindPrimes) {
                Alert(title: Text("Prime Finder encountered a serious problem!"), message: Text("No valid file path for Primes file."))}
            .disabled(pfViewModel.findNPrimesInProgress)

            //**********  FindNPrimes Button
            Button(pfViewModel.findNPrimesInProgress ? "   Running   " : "Find NPrimes", action: {
                if self.pfViewModel.findNPrimesInProgress {
                    self.pfViewModel.stopProcess()
                } else {
                    switch self.pfViewModel.findNicePrimes() {
                        
                        case .invalidDataError:
                            self.showErrorInvalidData = true
                        
                        case .badPrimesFilePathError:
                            self.pfViewModel.primesURL = nil
                            self.showErrorFindPrimes = true

                        case .badNicePrimesFilePathError:
                            self.pfViewModel.nicePrimesURL = nil
                            self.showErrorFindNicePrimes = true
                            break

                        case .noError:
                            break
                    }
                }
            })
            .alert(isPresented: $showErrorFindNicePrimes) {
                Alert(title: Text("Prime Finder encountered a serious problem!"), message: Text("No valid file path for NicePrimes file."))}
            .disabled(pfViewModel.findPrimesInProgress)
        }
    //    .frame(width: 500, height: 200, alignment: .center)
        Spacer()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PrimeFinderView()
    }
}
