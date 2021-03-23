//
//  ArticleRowView.swift
//  HLNews
//
//  Created by Matthew Homer on 3/23/21.
//

import SwiftUI

struct ArticleRowView: View {
    var article: Article
    var body: some View {
        Text(article.title)
    }
}

struct ArticleRowView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleRowView(article: Article.generateTestData())
    }
}
