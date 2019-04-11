//
//  HLDataProvider.swift
//  MinkoPlayer
//
//  Created by Matthew Homer on 4/8/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

import UIKit

protocol HLDataProviderProtocol {
    func JSONDownloadCompleted(result: Any)
    func JSONDownloadFailed(error: String)
}


class HLDataProvider: NSObject {

//  singleton class
    static let sharedInstance = HLDataProvider()
    var session: URLSession?
    let tempAppVer = "0.1.2.3"

    let timeoutLimit = 4.0
    let baseURL = "https://raw.seeotter.tv/api/index.php/appletv/"
    //let baseURL = "https://test.minko.int/api/index.php/appletv/"
    let appName = "funston"
    var requestVideosCommand: HLRequestVideosCommand?
    
    
    func requestData(delegate: HLDataProviderProtocol)  {
        let url = URL(string: baseURL + "app_videos_new/martha/0/20/" + tempAppVer)!

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error == nil {
                if let dt = data {
         //           let str = String(data: dt, encoding: .utf8)
         //           print("data1: \(String(describing: str))")
                    
                    
                    do {
                        let decoder = JSONDecoder()
                        self.requestVideosCommand = try decoder.decode(HLRequestVideosCommand.self, from: dt     )
             //           print("requestVideosCommand:  \(self.requestVideosCommand).")
                        print("requestVideosCommanddata:  \(self.requestVideosCommand!.data).")

                        DispatchQueue.main.async { [unowned self] in
                            delegate.JSONDownloadCompleted(result: self.requestVideosCommand as Any)
                        }

                }
                    catch {
                        print("Serious Error: no data.")
                        delegate.JSONDownloadFailed(error: "Serious Error: no data.")
                    }
                    
                }
            }
        }
        
        task.resume()

    }

    private override init()  {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeoutLimit
        session = URLSession(configuration: config)
    }

 }
