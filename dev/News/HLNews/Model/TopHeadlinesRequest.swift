//
//  TopHeadlinesRequest.swift
//  HLNews
//
//  Created by Matthew Homer on 3/22/21.
//

import Foundation

public struct TopHeadlinesRequest: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

extension TopHeadlinesRequest: CustomStringConvertible {
    public var description: String {
        "TopHeadlinesRequest:  totalResults: \(totalResults)  status: \(status)"
    }
}
