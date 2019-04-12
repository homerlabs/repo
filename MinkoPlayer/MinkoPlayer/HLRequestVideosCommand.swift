//
//  HLRequestVideosCommand.swift
//  MinkoPlayer
//
//  Created by Matthew Homer on 4/7/19.
//  Copyright © 2019 Matthew Homer. All rights reserved.
//

import UIKit

class HLRequestVideosCommand: NSObject, Decodable {
    let totalCount: Int
    let offset: Int
    let title: String
    let type: String
    let timeSpent: Int
    let data: [HLVideo]
    
    override var description : String    {
        return "HLRequestVideosCommand-  totalCount: \(totalCount)  offset: \(offset)  timeSpent: \(timeSpent)  type: \(type)  title: \(title)  videos: \(data.count))"
    }

    init(totalCount: Int, offset: Int, title: String, type: String, timeSpent: Int, data: [HLVideo])    {
        self.totalCount = totalCount
        self.offset = offset
        self.title = title
        self.type = type
        self.timeSpent = timeSpent
        self.data = data
    }
}
