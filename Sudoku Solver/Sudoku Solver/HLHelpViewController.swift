//
//  HLHelpViewController.swift
//  Sudoku Solver
//
//  Created by Matthew Homer on 2/25/18.
//  Copyright © 2018 Homer Labs. All rights reserved.
//

import UIKit

class HLHelpViewController: UIViewController {

    @IBOutlet weak var hlWebView: UIWebView!
    var pdfPath: String!


    override func viewDidLoad() {
        super.viewDidLoad()

        if let pdfURL = Bundle.main.url(forResource: "Overview", withExtension: "pdf", subdirectory: nil, localization: nil)  {
            let urlRequest = URLRequest(url: pdfURL)
            hlWebView.loadRequest(urlRequest)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
