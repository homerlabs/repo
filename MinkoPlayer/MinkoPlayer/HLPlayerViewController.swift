//
//  HLPlayerViewController.swift
//  MinkoPlayer
//
//  Created by Matthew Homer on 4/11/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

import UIKit
import WebKit

class HLPlayerViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {

   @IBOutlet weak var webView: WKWebView!
   var urlString: String?

    private func displayWebPage() {
    
        if let urlString = urlString    {
            guard let url = URL(string: urlString)  else {  return  }
            let request = URLRequest(url: url)
            webView.navigationDelegate = self
            webView.uiDelegate = self
 
 /*       let contentController = WKUserContentController()
        let userScript = WKUserScript(
            source: "mobileHeader()",
            injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
            forMainFrameOnly: true
        )
        contentController.addUserScript(userScript)
        contentController.add(self, name: "loginAction")

            let config = WKWebViewConfiguration()
            config.userContentController = contentController    */
 
       
            webView.load(request)
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("webView-  didCommit")

/*        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in
   //         print("timertimertimertimer")
             webView.evaluateJavaScript("iosTest2(‘some text goes here’)", completionHandler: { any, error in
                print("timer evaluateJavaScript  any\(String(describing: any))  error\(String(describing: error))")
            })
        })  */
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webView-  didFinish")

         webView.evaluateJavaScript("iosRequest22()", completionHandler: { any, error in
            print("evaluateJavaScript  any\(String(describing: any))  error\(String(describing: error))")
        })
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("webView-  didFail")
        print(error)
    }
    
    @IBAction func backButtonAction(sender: UIButton)   {
 //       print("backButtonAction")
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        displayWebPage()
    }
    

    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "loginAction" {
            print("JavaScript is sending a message \(message.body)")
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
