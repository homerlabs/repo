//
//  HLDetailViewController.swift
//  Sudoku Solver
//
//  Created by Matthew Homer on 1/23/16.
//  Copyright © 2016 Homer Labs. All rights reserved.
//

import UIKit

class HLDetailViewController: UIViewController {

    @IBOutlet weak var pdfWebView: UIWebView?

    override func viewDidLoad() {
        super.viewDidLoad()

    let pdfLoc = NSURL(fileURLWithPath:NSBundle.mainBundle().pathForResource("Overview", ofType:"pdf")!)
    let request = NSURLRequest(URL: pdfLoc);
    self.pdfWebView!.loadRequest(request);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
