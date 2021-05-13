//
//  ArticleDetailView.swift
//  HLNews
//"
//  Created by Matthew Homer on 3/26/21.
//

import SwiftUI
import WebKit

struct ArticleDetailView: UIViewRepresentable {
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView  {
        //  disable javascript
        let configuration = WKWebViewConfiguration()
        
        //  have to tolerate warning for now as the next line dose not work
        configuration.preferences.javaScriptEnabled = false
        configuration.defaultWebpagePreferences.allowsContentJavaScript = false

      //  let webView = WKWebView()
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}

struct ArticleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleDetailView(urlString: "https://nypost.com/2021/03/26/jen-psaki-says-biden-will-sign-gun-control-executive-orders/")
    }
}
