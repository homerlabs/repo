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
    @Published var status = "Idle"
    @Published var primesURL: URL?
    @Published var nicePrimesURL: URL?
    var primeFinder: HLPrime?
    
    func setBookMark() {
/*        if let url = primesURL {
            url.setBookmarkFor(key: HLPrime.PrimesBookmarkKey)
        }*/
    }
}
