//
//  HLArticleTableViewCell.swift
//  HLNewsSB
//
//  Created by Matthew Homer on 4/3/21.
//

import UIKit

class HLArticleTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var urlToImageView: AsyncImageView!
    let placeholderImage = UIImage(named: "Background100x100.png")

    
    var urlString: String? {
        didSet {
            if let url = urlString {
                urlToImageView.loadAsyncFrom(url: url, placeholder: placeholderImage)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
   //    urlToImageView.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
  //      print("setSelected")
        // Configure the view for the selected state
    }
    
}
