//
//  HLPlayerViewController.swift
//  MinkoPlayer
//
//  Created by Matthew Homer on 4/11/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

import UIKit
import WebKit

class HLPlayerViewController: UIViewController, WKNavigationDelegate {

   @IBOutlet weak var webView: WKWebView!
   var urlString: String?

    private func displayWebPage() {
        if let urlString = urlString    {
            guard let url = URL(string: urlString)  else {  return  }
            let request = URLRequest(url: url)
            webView.navigationDelegate = self
            webView.load(request)
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        displayWebPage()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
