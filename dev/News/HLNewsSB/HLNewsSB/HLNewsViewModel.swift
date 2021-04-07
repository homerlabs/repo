//
//  HLNewsViewModel.swift
//  HLNews
//
//  Created by Matthew Homer on 3/21/21.
//

import Foundation
//  https://newsapi.org/docs
//  https://newsapi.org/v2/everything?q=Apple&from=2021-04-07&sortBy=popularity&apiKey=API_KEY

protocol LoadRequestComplete: class {
    func dataReady(data: [Article])
}

//  this class has been repurposed and no longer is a viewModel
//  it should be rewritten or at the least renamed
class HLNewsViewModel {
    let API_KEY = "&apiKey=0e1e28addfd5486ca24055fdd8d2048b"
    let baseHTTPString = "https://newsapi.org/v2/"

    var delegate: LoadRequestComplete?
    
    func fetchSearch(_ search: String) {
        let everythingHTTPString = String(format: "%@everything?q=%@&sortBy=popularity%@", baseHTTPString, search, API_KEY)
        print("fetchSearch-  \(everythingHTTPString)")

        if let url = URL(string: everythingHTTPString) {
            fetch(url: url)
        }
    }
    
    func fetch(url: URL) {
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
                            self.delegate?.dataReady(data: topHeadlinesRequest.articles)
                            
                            for item in topHeadlinesRequest.articles {
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
    
    func fetchTopHeadlines() {
        let topHeadlinesHTTPString = String(format: "%@top-headlines?country=us%@", baseHTTPString, API_KEY)
        print("fetchTopHeadlines-  \(topHeadlinesHTTPString)")
        
        if let url = URL(string: topHeadlinesHTTPString) {
            fetch(url: url)
        }
    }
}
