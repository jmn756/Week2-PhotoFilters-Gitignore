//
//  ImageResizer.swift
//  ParseStarterProject
//
//  Created by Joey Nessif on 8/12/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class ImageResizer {
  class func resizeImage(image : UIImage, size : CGSize) -> UIImage {
    
    UIGraphicsBeginImageContext(size)
    image.drawInRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return resizedImage
  }
}
