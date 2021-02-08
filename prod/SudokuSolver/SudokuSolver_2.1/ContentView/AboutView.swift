//
//  AboutView.swift
//  SudokuSolver
//
//  Created by Matthew Homer on 5/12/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import SwiftUI
import WebKit

struct AboutView : UIViewRepresentable {

    func makeUIView(context: Context) -> WKWebView  {
        let webView = WKWebView()
        let path = Bundle.main.path(forResource: "Help/index", ofType: "htm")!
        let request = URLRequest(url: URL(fileURLWithPath: path))
        webView.load(request)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) { }
}

struct AboutView_Previews : PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
