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
    
    func makeUIView(context: Context) -> WKWebView  {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = false

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

struct WebViewContentView_Previews: PreviewProvider {
    static var previews: some View {
        WebViewContentView(urlString: "https://nypost.com/2021/03/26/jen-psaki-says-biden-will-sign-gun-control-executive-orders/")
    }
}
