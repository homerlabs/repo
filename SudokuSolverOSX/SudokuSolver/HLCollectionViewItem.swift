//
//  HLCollectionViewItem.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 12/8/18.
//  Copyright © 2018 Matthew Homer. All rights reserved.
//

import Cocoa

class HLCollectionViewItem: NSCollectionViewItem {

@IBOutlet weak var hlTextField: NSTextField!

  override func viewDidLoad() {
    super.viewDidLoad()
    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.lightGray.cgColor
  }
}
