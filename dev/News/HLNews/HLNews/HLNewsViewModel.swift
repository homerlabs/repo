//
//  HLNewsViewModel.swift
//  HLNews
//
//  Created by Matthew Homer on 3/21/21.
//

import SwiftUI
//    let httpString = "https://newsapi.org/v2/top-headlines?country=us&apiKey=0e1e28addfd5486ca24055fdd8d2048b"

class HLNewsViewModel: ObservableObject {
    @Published var searchString: String = ""
    static var lastURL: URL?
    
    let API_KEY = "&apiKey=0e1e28addfd5486ca24055fdd8d2048b"
    let baseHTTPString = "https://newsapi.org/v2/"

    @Published var articles: [Article] = []
    
    func fetchSearch(_ search: String) {
        let everythingHTTPString = String(format: "%@everything?q=%@&sortBy=popularity%@", baseHTTPString, search, API_KEY)
        print("fetchSearch-  \(everythingHTTPString)")

        if let url = URL(string: everythingHTTPString) {
            fetch(url: url)
        }
    }

    func fetch(url: URL) {
        HLNewsViewModel.lastURL = url
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error == nil {
                if let dt = data {
            //        let str: String? = String(data: dt, encoding: String.Encoding.utf8)
            //        print("str: \(String(describing: str))")
                    //      let response = response as URLResponse?
                    //      print("response: \(String(describing: response))")
                    
               //     let jsonDict = try? JSONSerialization.jsonObject(with: dt, options: [])
               //     print("jsonDict: \(String(describing: jsonDict))")

                    let decoder = JSONDecoder()
                    do {
                        let topHeadlinesRequest: TopHeadlinesRequest = try decoder.decode(TopHeadlinesRequest.self, from: dt)
                        
                        DispatchQueue.main.async {
                            self.articles = topHeadlinesRequest.articles
                   //         for item in self.articles { item.output() }
                        }
                    }
                    catch {
                        print("\n........................error: \(error)")
                    }
                }
            }
        }
        task.resume()
    }
    
    func refreshContent() {
        print("refreshContent-  lastURL: \(String(describing: HLNewsViewModel.lastURL))")
        if let url = HLNewsViewModel.lastURL {
            fetch(url: url)
        }
    }

    func fetchTopHeadlines() {
        let topHeadlinesHTTPString = String(format: "%@top-headlines?country=us%@", baseHTTPString, API_KEY)
        print("fetchTopHeadlines-  \(topHeadlinesHTTPString)")
        
        if let url = URL(string: topHeadlinesHTTPString) {
            fetch(url: url)
        }
    }
}
