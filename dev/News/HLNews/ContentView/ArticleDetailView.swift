//
//  ArticleDetailView.swift
//  HLNews
//"
//  Created by Matthew Homer on 3/26/21.
//

import SwiftUI

struct ArticleDetailView: View {
    let urlString: String
    @State var javaScriptEnabled = true
    
    var body: some View {
        NavigationView {
            WebViewContentView(urlString: urlString, javascriptEnabled: javaScriptEnabled)
        }
        .navigationBarItems(trailing: Button(action: {
            javaScriptEnabled.toggle()
            updateWebView()
        },
            label: {Text(javaScriptEnabled ? "JS Enabled" : "JS Disabled")})
        )
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func updateWebView() {
        let _ = WebViewContentView(urlString: urlString, javascriptEnabled: javaScriptEnabled)
    }
}
