//
//  WebViewContentView.swift
//  HLNews
//
//  Created by Matthew Homer on 5/24/21.
//

import SwiftUI
import WebKit

struct WebViewContentView: UIViewRepresentable {
    let urlString: String
    let javascriptEnabled: Bool
    
    func makeUIView(context: Context) -> WKWebView  {
        //  configure javascript
        let configuration = WKWebViewConfiguration()
        
        //  have to tolerate warning for now as the next line dose not work
        configuration.preferences.javaScriptEnabled = javascriptEnabled
        configuration.defaultWebpagePreferences.allowsContentJavaScript = false

        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
  //      print("makeUIView-  javascriptEnabled: \(javascriptEnabled)  urlString: \(urlString)")
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}

struct WebViewContentView_Previews: PreviewProvider {
    static var previews: some View {
        WebViewContentView(urlString: "https://nypost.com/2021/03/26/jen-psaki-says-biden-will-sign-gun-control-executive-orders/", javascriptEnabled: true)
    }
}
