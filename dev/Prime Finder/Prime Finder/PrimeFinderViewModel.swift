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
    case badPrimesFilePathError
    case badNicePrimesFilePathError
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
        if primesURL == nil {
            primesURL = fileManager.getURLForWritting(title: "Prime Finder Save Panel", message: "Create Primes file", filename: "Primes")
        }
        guard primesURL != nil else { return .badPrimesFilePathError }
        
        setupTimer()
        let maxPrime = HLPrimeType(terminalPrime)
        findPrimesInProgress = true

        primeFinder.findPrimes(primeURL: primesURL!, maxPrime: maxPrime) { [weak self] result in
            guard let self = self else { return }
            
            let elaspedTime = self.primeFinder.timeInSeconds.formatTime()
            print("    *********  findPrimes completed in \(elaspedTime)       ********* \n")
            self.timer.invalidate()
            self.findPrimesInProgress = false
            let (lastN, lastP) = result.parseLine()
            self.status = "Last Prime Processed (lastN : lastP): \(lastN) : \(lastP)"
            self.fileManager.setBookmarkForURL(self.primesURL, key: HLPrime.HLPrimesURLKey)

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
        if !fileManager.isFileFound(url: primesURL) {
            primesURL = fileManager.getURLForReading(url: nil)
        }
        
        //  if we don't have a good url to the primes file we can't continue
        //  this will happen if there is no primes file or the user can't find it
        guard primesURL != nil else { return .badPrimesFilePathError }

        if nicePrimesURL == nil {
            nicePrimesURL = fileManager.getURLForWritting(title: "Prime Finder Save Panel", message: "Create NicePrimes file", filename: "NPrimes")
        }
        guard nicePrimesURL != nil else { return .badNicePrimesFilePathError }

        setupTimer()
        findNPrimesInProgress = true
        fileManager.setBookmarkForURL(primesURL, key: HLPrime.HLPrimesURLKey)

        primeFinder.makeNicePrimesFile(primeURL: primesURL!, nicePrimeURL: nicePrimesURL!) { [weak self] result in
            guard let self = self else { return }

            let elaspedTime = self.primeFinder.timeInSeconds.formatTime()
            print("    *********  findNicePrimes completed in \(elaspedTime)       ********* \n")
            self.timer.invalidate()
            self.findNPrimesInProgress = false
            let (lastN, lastP) = result.parseLine()
            self.status = "Last Prime Processed (lastN : lastP): \(lastN) : \(lastP)"
            self.fileManager.setBookmarkForURL(self.nicePrimesURL, key: HLPrime.HLNicePrimesKey)

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
    func setupTimer()  {
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
        primeFinder.okToRun = false
        primesURL?.stopAccessingSecurityScopedResource()
        nicePrimesURL?.stopAccessingSecurityScopedResource()
        NSApplication.shared.terminate(self)    //  quit app if dealloc
    }
}
