//
//  HLVideo.swift
//  MinkoPlayer
//
//  Created by Matthew Homer on 4/6/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

import UIKit

class HLVideo: NSObject, Decodable {
    let id: String
    let db_channel_id: String
    let yt_id: String
    let views: String
    let duration: String
    let title: String
    let thumb_medium: String
    let thumb_high: String
    let thumb_maxres: String?

    override var description : String    {
        return "HLVideo-  id: \(id)  db_channel_id: \(db_channel_id)  yt_id: \(yt_id)  thumb_medium: \(thumb_medium)  thumb_high: \(thumb_high)  duration: \(duration)\n)"
    }

    init(id: String, db_channel_id: String, yt_id: String, views: String, duration: String, title: String, thumb_medium: String, thumb_high: String, thumb_maxres: String?)    {
        self.id = id
        self.db_channel_id = db_channel_id
        self.yt_id = yt_id
        self.views = views
        self.duration = duration
        self.title = title
        self.thumb_medium = thumb_medium
        self.thumb_high = thumb_high
        self.thumb_maxres = thumb_maxres
//        print("HLVideo-  id: \(id)   db_channel_id: \(db_channel_id)   yt_id: \(yt_id)  duration: \(duration)\n")
    }
}
