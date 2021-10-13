//
//  ArticleDetailView.swift
//  HLNews
//"
//  Created by Matthew Homer on 3/26/21.
//

import SwiftUI

struct ArticleDetailView: View {
    let urlString: String
    
    var body: some View {
        NavigationView {
            WebViewContentView(urlString: urlString)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func updateWebView() {
        let _ = WebViewContentView(urlString: urlString)
    }
}
