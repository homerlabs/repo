//
//  ViewController.swift
//  FetchPuzzles
//
//  Created by Matthew Homer on 12/4/20.
//

import Cocoa

class ViewController: NSViewController, PuzzleFactoryProtocol {
    
    @IBOutlet weak var button: NSButton!
    var isActive = false
    var puzzleFatory = PuzzleFactory()
    var timer: Timer?
    var table: [HLSolver] = []
    var tableURL: URL?
    let dataFileKey = "dataFileName"

    override func viewDidLoad() {
        super.viewDidLoad()
        puzzleFatory.delegate = self
        tableURL = dataFileKey.getBookmark()
        print("tableURL: \(String(describing: tableURL))")
        tableURL = dataFileKey.getSaveFilePath(title: "FetchPuzzles", message: "Set path for Plist file")
        print("tableURL: \(String(describing: tableURL))")
        
        guard tableURL != nil else {
            print("Warning!  tableURL is NIL!!")
            return
        }
        
        //  load table if present
        let plistDecoder = PropertyListDecoder()
        if let data = try? Data(contentsOf: tableURL!) {
            if let table = try? plistDecoder.decode([HLSolver].self, from:data) {
                self.table = table
            }
        }
        print("table.count: \(table.count)")
    }
    
    @IBAction func buttonTapped(sender: NSButton) {
        isActive.toggle()
        print("buttonTapped-  isActive: \(isActive)")
        if isActive {
            button.title = "Stop"
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { timer in
                print("timer fired")
                let id = String(self.table.count+1)
                self.puzzleFatory.getNewPuzzle(id)
            })
        } else {
            button.title = "Start"
            timer?.invalidate()
        }
    }
    
    func puzzleReady(puzzle: HLSolver?) {
        if let puzzle = puzzle {
            print("puzzleReady-  puzzle: \(puzzle)")
            table.append(puzzle)
            
            let plistEncoder = PropertyListEncoder()
            if let data = try? plistEncoder.encode(table) {
                try? data.write(to: tableURL!)
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

