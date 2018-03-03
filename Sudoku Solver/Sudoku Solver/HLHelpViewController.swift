//
//  HLHelpViewController.swift
//  Sudoku Solver
//
//  Created by Matthew Homer on 2/25/18.
//  Copyright © 2018 Homer Labs. All rights reserved.
//

import UIKit
import WebKit

class HLHelpViewController: UIViewController {

    @IBOutlet weak var hlWebView: WKWebView!
    var pdfPath: String!


    override func viewDidLoad() {
        super.viewDidLoad()

        if let pdfURL = Bundle.main.url(forResource: "Overview", withExtension: "pdf", subdirectory: nil, localization: nil)  {
            let urlRequest = URLRequest(url: pdfURL)
            hlWebView.load(urlRequest)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
