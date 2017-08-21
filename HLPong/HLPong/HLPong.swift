//
//  HLPong.swift
//  HLPong
//
//  Created by Matthew Homer on 8/15/17.
//  Copyright © 2017 HomerLabs. All rights reserved.
//

import UIKit

class HLPong: NSObject {

    var imageView: UIImageView!
    var velocityX: CGFloat = 1.0
    var velocityY: CGFloat = 1.0
    
    init(imageName: String, xVelocity: CGFloat, yVelocity: CGFloat) {
        imageView = UIImageView(image: UIImage(named: imageName)!)
        velocityX = xVelocity
        velocityY = yVelocity
    }

}
