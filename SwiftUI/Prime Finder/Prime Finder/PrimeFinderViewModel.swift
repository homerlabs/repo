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
    @Published var terminalPrime = "1000"
    @Published var findPrimesInProgress = false
    @Published var findNPrimesInProgress = false
    @Published var status = "Idle"
    @Published var progress = "0"
    @Published var primesURL: URL?
    @Published var nicePrimesURL: URL?
    
    private var primeFinder: HLPrime
    private var timer = Timer()
    private var updateTimeInSeconds = 4.0
    private let startingMessage = "Starting ..."
    
    //  returns HLErrorEnum
    func findPrimes() -> HLErrorEnum {
        
        guard HLPrimeType(terminalPrime) != nil else { return .invalidDataError }

        let result = setup(primesURL)
        if result != .noError {
            return result
        }

        findPrimesInProgress = true
        let maxPrime = HLPrimeType(terminalPrime)!
        
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
                let percent = Int(Double(self.primeFinder.lastP) / Double(self.terminalPrime)! * 100)
                self.progress = String(percent)
            }
            
            let isValid = self.primeFinder.primeFileIsValid()
            if !isValid {
                print("    *********  findPrimes completed but primeFileIsValid() failed!!       ********* \n")
            }
        }
        
        return .noError
    }
    
    //  returns HLErrorEnum
    func findNPrimes() -> HLErrorEnum {
        
        let result = setup(primesURL)
        if result != .noError {
            return result
        }
        
        findNPrimesInProgress = true

        primeFinder.makeNicePrimesFile(nicePrimeURL: nicePrimesURL!) { [weak self] result in
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
                let percent = Int(Double(self.primeFinder.lastP) / Double(self.terminalPrime)! * 100)
                self.progress = String(percent)
            }
        }
        
        return .noError
    }
    
    //  returns HLErrorEnum
    //  checks primesURL by performing a file open (then close)
    //  sets up timer for status and progress updates
    func setup(_ primesURL: URL?) -> HLErrorEnum {
        primeFinder.primesFileURL = primesURL
        guard primeFinder.isPrimeURLValid() else { return .badFilePathError }
        
        status = startingMessage
        progress = "0"
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: updateTimeInSeconds, repeats: true, block: { _ in
            self.status = "Processed (lastN : lastP): \(self.primeFinder.lastN) : \(self.primeFinder.lastP)"
            let percent = Int(Double(self.primeFinder.lastP) / Double(self.terminalPrime)! * 100)
            self.progress = String(percent)
        })
        
        return .noError
    }
    
    func stopProcess() {
        primeFinder.okToRun = false
    }

    init() {
        print("PrimeFinderViewModel-  init")
        primeFinder = HLPrime()
        primesURL = HLPrime.HLPrimesBookmarkKey.getBookmark()
        nicePrimesURL = HLPrime.HLNicePrimesBookmarkKey.getBookmark()
        let value = UserDefaults.standard.integer(forKey: HLPrime.HLTerminalPrimeKey)
        if value > 0 {
            terminalPrime = String(value)
        }
    }
    
    deinit {
        print("PrimeFinderViewModel-  deinit")
        if let url = primesURL {
            url.setBookmarkFor(key: HLPrime.HLPrimesBookmarkKey)
        }
        
        if let url = nicePrimesURL {
            url.setBookmarkFor(key: HLPrime.HLNicePrimesBookmarkKey)
        }
        
        if let value = HLPrimeType(terminalPrime) {
            UserDefaults.standard.set(value, forKey: HLPrime.HLTerminalPrimeKey)
        }
        
        primeFinder.okToRun = false
        primesURL?.stopAccessingSecurityScopedResource()
        nicePrimesURL?.stopAccessingSecurityScopedResource()
        NSApplication.shared.terminate(self)    //  quit app if dealloc
    }
}
