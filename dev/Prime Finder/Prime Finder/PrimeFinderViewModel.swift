//
//  PrimeFinderViewModel.swift
//  Prime Finder
//
//  Created by Matthew Homer on 2/24/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import Foundation
import Cocoa

enum HLErrorEnum {
    case noError
    case badFilePathError
    case invalidDataError
}

class PrimeFinderViewModel: ObservableObject {
    @Published var terminalPrime = HLPrimeType(1000)
    @Published var findPrimesInProgress = false
    @Published var findNPrimesInProgress = false
    @Published var status = "Idle"
    @Published var progress = "0"
    @Published var primesURL: URL?
    @Published var nicePrimesURL: URL?
    
    private let fileManager = HLFileManager.shared

    private var primeFinder: HLPrime
    private var timer = Timer()
    private var updateTimeInSeconds = 4.0
    private let startingMessage = "Starting ..."
    
    //  returns HLErrorEnum
    func findPrimes() -> HLErrorEnum {
        primeFinder.primesFileURL = primesURL
        setup()
        findPrimesInProgress = true
        let maxPrime = HLPrimeType(terminalPrime)
        
        primeFinder.findPrimes(maxPrime: maxPrime) { [weak self] result in
            guard let self = self else { return }
            
            let elaspedTime = self.primeFinder.timeInSeconds.formatTime()
            print("    *********  findPrimes completed in \(elaspedTime)       ********* \n")
            self.timer.invalidate()
            self.findPrimesInProgress = false
            let (lastN, lastP) = result.parseLine()
            self.status = "Last Prime Processed (lastN : lastP): \(lastN) : \(lastP)"
            
            if self.primeFinder.okToRun {
                self.progress = "100"
            } else {
                let percent = Int(Double(self.primeFinder.lastP) / Double(self.terminalPrime) * 100)
                self.progress = String(percent)
            }
        }
        
        return .noError
    }
    
    //  returns HLErrorEnum
    func findNicePrimes() -> HLErrorEnum {
        primeFinder.primesFileURL = primesURL
        guard primeFinder.isFileFound(url: primesURL) else { return .badFilePathError }

        setup()
        findNPrimesInProgress = true

        primeFinder.makeNicePrimesFile(primeURL: primesURL, nicePrimeURL: nicePrimesURL) { [weak self] result in
            guard let self = self else { return }

            let elaspedTime = self.primeFinder.timeInSeconds.formatTime()
            print("    *********  findNicePrimes completed in \(elaspedTime)       ********* \n")
            self.timer.invalidate()
            self.findNPrimesInProgress = false
            let (lastN, lastP) = result.parseLine()
            self.status = "Last Prime Processed (lastN : lastP): \(lastN) : \(lastP)"
            
            if self.primeFinder.okToRun {
                self.progress = "100"
            } else {
                let percent = Int(Double(self.primeFinder.lastP) / Double(self.terminalPrime) * 100)
                self.progress = String(percent)
            }
        }
        
        return .noError
    }
    
    //  sets up timer for status and progress updates
    func setup()  {
        status = startingMessage
        progress = "0"
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: updateTimeInSeconds, repeats: true, block: { _ in
            self.status = "Processed (lastN : lastP): \(self.primeFinder.lastN) : \(self.primeFinder.lastP)"
            let percent = Int(Double(self.primeFinder.lastP) / Double(self.terminalPrime) * 100)
            self.progress = String(percent)
        })
    }
    
    func stopProcess() {
        primeFinder.okToRun = false
    }

    init() {
        primeFinder = HLPrime()
        
        primesURL = fileManager.getBookmark(HLPrime.HLPrimesURLKey)
        nicePrimesURL = fileManager.getBookmark(HLPrime.HLNicePrimesKey)
 //       print("PrimeFinderViewModel-  init-  primesURL: \(String(describing: primesURL))")

        if let valueP = UserDefaults.standard.object(forKey: HLPrime.HLTerminalPrimeKey) as? NSNumber {
            terminalPrime = valueP.int64Value
        }
    }
    
    deinit {
  //      print("PrimeFinderViewModel-  deinit")
        fileManager.setBookmarkForURL(primesURL, key: HLPrime.HLPrimesURLKey)
        fileManager.setBookmarkForURL(nicePrimesURL, key: HLPrime.HLNicePrimesKey)
                
        primeFinder.okToRun = false
        primesURL?.stopAccessingSecurityScopedResource()
        nicePrimesURL?.stopAccessingSecurityScopedResource()
        NSApplication.shared.terminate(self)    //  quit app if dealloc
    }
}
