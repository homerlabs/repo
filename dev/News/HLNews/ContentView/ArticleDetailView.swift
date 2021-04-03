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
        Text("urlString: \(urlString)")
    }
}

struct ArticleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleDetailView(urlString: "https://nypost.com/2021/03/26/jen-psaki-says-biden-will-sign-gun-control-executive-orders/")
    }
}
