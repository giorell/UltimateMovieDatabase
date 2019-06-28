//
//  UIImage+Extensions.swift
//  Capstone_UltimateMDB
//
//  Created by Giordany Orellana on 6/21/19.
//  Copyright © 2019 Giordany Orellana. All rights reserved.
//

import Foundation
import UIKit


extension UIImage {
    
    func roundedImage() -> UIImage {
        let imageView: UIImageView = UIImageView(image: self)
        let layer = imageView.layer
        layer.cornerRadius = imageView.frame.width / 2
        layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage!
    }
    
    func roundedCorners() -> UIImage {
        let imageView: UIImageView = UIImageView(image: self)
        let layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = 20
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedCornersImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedCornersImage!
        
    }
}
