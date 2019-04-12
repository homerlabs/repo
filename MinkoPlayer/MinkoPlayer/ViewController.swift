//
//  ViewController.swift
//  MinkoPlayer
//
//  Created by Matthew Homer on 4/6/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

import UIKit

class ViewController: UIViewController, HLDataProviderProtocol, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    let cellReuseIdentifier = "VideoCellId"
    var requestVideosCommand = HLRequestVideosCommand(totalCount: 0, offset: 0, title: "", type: "", timeSpent: 0, data: [])
    let dataProvider = HLDataProvider.sharedInstance
    
    var imageCache: [String:UIImage] = [:]

    public func imageFromUrl(urlString: String) {
        if let url = URL(string: urlString) {
           let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    if let imageData = data as NSData? {
                        let image = UIImage(data: imageData as Data)
                        
                        DispatchQueue.main.async { [unowned self] in
                            self.imageCache[urlString] = image  //  modify imageCache on main thread
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            
            task.resume()
        }
    }

  func JSONDownloadCompleted (result: Any)
  {
        if let result = result as? HLRequestVideosCommand   {
            requestVideosCommand = result
            self.tableView.reloadData()
    }
  }

  func JSONDownloadFailed (error: String)
  {
//    HLVideo.processing -= 1
    print( "HLVideo-  JSONDownloadFailed: \(error)" )
  }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "HLVideoTableViewCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        dataProvider.requestData(delegate: self)
    }


    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestVideosCommand.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! HLVideoTableViewCell
//        cell.textLabel?.text = cats[indexPath.row].id
        cell.id?.text = requestVideosCommand.data[indexPath.row].id
        cell.yt_id?.text = requestVideosCommand.data[indexPath.row].yt_id
        
        let urlString = requestVideosCommand.data[indexPath.row].thumb_medium
        
        if let image = imageCache[urlString]    {
            cell.videoImageView?.image = image
        }
        else    {
            //  async fetch image 
            self.imageFromUrl(urlString: urlString)
        }
        
        return cell;
    }

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let yt_id = requestVideosCommand.data[indexPath.row].yt_id
   //     let urlString = "https://www.youtube.com/watch?v=" + yt_id
   //     let urlString = "http://dev.homerlabs.us/ytsupport/index.html"
    //    let urlString = "http://apple.seeotter.tv/ios/index3.php?videoID=uVOGnAT9g7Q&width=1280&height=720&device=iPad&exit=true"
        let urlString = "http://apple.seeotter.tv/ios/index3.php?videoID=" + yt_id + "&width=1280&height=720&device=iPad&exit=true"
  //      print("urlString: \(urlString).")
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "HLPlayer") as! HLPlayerViewController
        next.urlString = urlString
        self.present(next, animated: true, completion: nil)
    }
}

