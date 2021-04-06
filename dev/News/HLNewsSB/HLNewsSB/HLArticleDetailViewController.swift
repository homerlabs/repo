//
//  HLArticleDetailViewController.swift
//  HLNewsSB
//
//  Created by Matthew Homer on 4/5/21.
//

import UIKit
import WebKit

class HLArticleDetailViewController: UIViewController, WKNavigationDelegate {

 //   let url = URL(string: "https://nine.websudoku.com/?level=4&set_id=8543506682")
    @IBOutlet weak var hlWebView : WKWebView!
    var article: Article?

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        print("HLArticleDetailViewController-  webView-  didFinish")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
   //     hlWebView.j

        print("HLArticleDetailViewController-  viewDidLoad")
        if let urlString = article?.url {
            if let url = URL(string: urlString) {
                hlWebView.load(URLRequest(url: url))
            }
        }
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
