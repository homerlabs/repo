//
//  ViewController.swift
//  HLNewsSB
//
//  Created by Matthew Homer on 4/3/21.
//

import UIKit
import Combine
//  https://newsapi.org/docs
//  http://www.mypet.com/img/basic-pet-care/how-long-leave-cat-alone-lead.jpg

class ViewController: UIViewController, LoadRequestComplete {
    
    @IBOutlet weak var tableView: UITableView!
    var newsViewModel = HLNewsViewModel()
    let cellReuseIdentifier = "ArticleCellId"
    let placeholderImage = UIImage(named: "Background100x100.png")
    
    var articles: [Article] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "HLArticleTableViewCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        newsViewModel.delegate = self
        newsViewModel.fetchTopHeadlines()
    }
    
    func dataReady(data: [Article]) {
        print("dataReady")
        articles = data
        tableView.reloadData()
    }


}

extension ViewController: UITableViewDataSource {
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! HLArticleTableViewCell
        let article = articles[indexPath.row]
        cell.title.text = article.title
        cell.author.text = article.author
    //    cell.urlString = article.urlToImage
        return cell;
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }

}

