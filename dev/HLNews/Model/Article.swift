//
//  Article.swift
//  HLNews
//
//  Created by Matthew Homer on 3/22/21.
//

import Foundation

public struct Source: Codable {
    let id: String?
    let name: String
}

public struct Article: Codable {
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?

    public static func generateTestData() -> Article {
        let source = Source(id: nil, name: "Name")
        return Article(source: source, author: nil, title: "Title", description: nil, url: "URL", urlToImage: nil, publishedAt: "publishedAt", content: nil)
    }
    
    public func output() {
        print("Article-  title: \(title) author: \(String(describing: author))")
    }
}
