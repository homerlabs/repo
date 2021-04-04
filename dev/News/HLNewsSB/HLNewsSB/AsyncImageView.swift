//
//  AsyncImageView.swift
//  HLNewsSB
//
//  Created by Matthew Homer on 4/3/21.
//

//import Foundation
import UIKit

//MARK: - 'asyncImagesCashArray' is a global varible cashed UIImage
var asyncImagesCashArray = NSCache<NSString, UIImage>()

class AsyncImageView: UIImageView {

//MARK: - Variables
private var currentURL: NSString?

//MARK: - Public Methods

func loadAsyncFrom(url: String, placeholder: UIImage?) {
    let imageURL = url as NSString
    if let cashedImage = asyncImagesCashArray.object(forKey: imageURL) {
        image = cashedImage
        return
    }
    image = placeholder
    currentURL = imageURL
    guard let requestURL = URL(string: url) else { image = placeholder; return }
    URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
        DispatchQueue.main.async { [weak self] in
            if error == nil {
                if let imageData = data {
                    if self?.currentURL == imageURL {
                        if let imageToPresent = UIImage(data: imageData) {
                            asyncImagesCashArray.setObject(imageToPresent, forKey: imageURL)
                            self?.image = imageToPresent
                        } else {
                            self?.image = placeholder
                        }
                    }
                } else {
                    self?.image = placeholder
                }
            } else {
                self?.image = placeholder
            }
        }
    }.resume()
}
}
