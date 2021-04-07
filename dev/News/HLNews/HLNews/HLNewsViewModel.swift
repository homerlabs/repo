//
//  HLNewsViewModel.swift
//  HLNews
//
//  Created by Matthew Homer on 3/21/21.
//

import SwiftUI
//import Combine

class HLNewsViewModel: ObservableObject {
    @Published var searchString: String = "Jeff Hawkens"
    @Published var resultString: String = """
    This is
    the multiline
    string.
    """
    
    let API_KEY = "0e1e28addfd5486ca24055fdd8d2048b"
    let httpString = "https://newsapi.org/v2/top-headlines?country=us&apiKey=0e1e28addfd5486ca24055fdd8d2048b"
    @Published var articles: [Article] = []
    
    func fetchTopHeadlines() {
        print("fetchTopHeadlines")
        if let url = URL(string: httpString) {
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    if let dt = data {
                //        let str: String? = String(data: dt, encoding: String.Encoding.utf8)
                //        print("str: \(String(describing: str))")
                        //      let response = response as URLResponse?
                        //      print("response: \(String(describing: response))")
                        
                        let jsonDict = try? JSONSerialization.jsonObject(with: dt, options: [])
                        print("jsonDict: \(String(describing: jsonDict))")

                        let decoder = JSONDecoder()
                        do {
                            let topHeadlinesRequest: TopHeadlinesRequest = try decoder.decode(TopHeadlinesRequest.self, from: dt)
                            
                            DispatchQueue.main.async {
                                self.articles = topHeadlinesRequest.articles
                                
                                for item in self.articles {
                                    item.output()
                                }
                            }
                        }
                        catch {
                            print("error: \(error)")
                        }
                    }
                }
            }
            task.resume()
        }
    }
}