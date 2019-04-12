//
//  HLVideoTableViewCell.swift
//  MinkoPlayer
//
//  Created by Matthew Homer on 4/7/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

import UIKit

class HLVideoTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var yt_id: UILabel!
    @IBOutlet weak var videoImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
