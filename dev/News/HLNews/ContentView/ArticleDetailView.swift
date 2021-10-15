//
//  ArticleDetailView.swift
//  HLNews
//"
//  Created by Matthew Homer on 3/26/21.
//

import SwiftUI

struct ArticleDetailView: View {
    let urlString: String
    let javascriptEnabled: Bool

    var body: some View {
        NavigationView {
            WebViewContentView(urlString: urlString, javascriptEnabled: javascriptEnabled)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func updateWebView() {
        let _ = WebViewContentView(urlString: urlString, javascriptEnabled: javascriptEnabled)
    }
}
