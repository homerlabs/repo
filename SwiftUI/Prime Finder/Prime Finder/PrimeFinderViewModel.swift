//
//  PrimeFinderViewModel.swift
//  Prime Finder
//
//  Created by Matthew Homer on 2/24/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import Foundation

class PrimeFinderViewModel: ObservableObject {
    @Published var terminalPrime = "1000"
    @Published var findPrimesInProgress = false
    @Published var findNPrimesInProgress = false
    @Published var status = "Idle"
    @Published var primesURL: URL?
    @Published var nicePrimesURL: URL?
    
    private var primeFinder: HLPrime
    private var timer = Timer()
    private var updateTimeInSeconds = 5.0
    
    //  returns true for success
    func findPrimes() -> Bool {
        print("PrimeFinderViewModel-  findPrimes")
        
        primeFinder.primesFileURL = primesURL
        let result = primeFinder.isPrimeURLValid()
        guard result else { return false }

        findPrimesInProgress = true
        status = ""
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: updateTimeInSeconds, repeats: true, block: { _ in
            self.status = "\(self.primeFinder.lastN) : \(self.primeFinder.lastP)"
        })
        
        //  TODO  handle non-int failure
        let maxPrime = HLPrimeType(terminalPrime)!
        primeFinder.findPrimes(maxPrime: maxPrime) { [weak self] result in
            guard let self = self else { return }
            let elaspedTime = self.primeFinder.timeInSeconds.formatTime()
            print("    *********  findPrimes completed in \(elaspedTime)       ********* \n")
            self.timer.invalidate()
            self.findPrimesInProgress = false
            let (lastN, lastP) = result.parseLine()
            self.status = "Last Prime Processed (lastN : lastP): \(lastN) : \(lastP)"
            
            let isValid = self.primeFinder.primeFileIsValid()
            if !isValid {
                print("    *********  findPrimes completed but primeFileIsValid() failed!!       ********* \n")
            }
        }
        
        return true
    }
    
    //  returns true for success
    func findNPrimes() -> Bool {
        
        //  not really neccessary as Find NPrimes button will be disabled if no urls
        guard primesURL != nil, nicePrimesURL != nil else { return false }
        
        primeFinder.primesFileURL = primesURL
        guard primeFinder.isPrimeURLValid() else { return false }
        
        
        findNPrimesInProgress = true
        status = ""
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: updateTimeInSeconds, repeats: true, block: { _ in
            self.status = "\(self.primeFinder.lastN) : \(self.primeFinder.lastP)"
        })

        primeFinder.makeNicePrimesFile(nicePrimeURL: nicePrimesURL!) { [weak self] result in
            guard let self = self else { return }

            let elaspedTime = self.primeFinder.timeInSeconds.formatTime()
            print("    *********  findNicePrimes completed in \(elaspedTime)       ********* \n")
            self.timer.invalidate()
            self.findNPrimesInProgress = false
            let (lastN, lastP) = result.parseLine()
            self.status = "Last Prime Processed (lastN : lastP): \(lastN) : \(lastP)"
        }
        
        return true
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
    }
}
