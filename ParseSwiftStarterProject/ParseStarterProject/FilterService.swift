//
//  FilterService.swift
//  ParseStarterProject
//
//  Created by Joey Nessif on 8/11/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class FilterService {
  
  class func applyFilter(image: UIImage, filter: String) -> UIImage {
  
    let image = CIImage(image: image)
    let photoFilter = CIFilter(name: filter)
    photoFilter.setValue(image, forKey: kCIInputImageKey)
    
    //gpu context
    let options = [kCIContextWorkingColorSpace : NSNull()]
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    let gpuContext = CIContext(EAGLContext: eaglContext, options: options)
    
    
    let outputImage = photoFilter.outputImage
    let extent = outputImage.extent()
    let cgImage = gpuContext.createCGImage(outputImage, fromRect: extent)
    let finalImage = UIImage(CGImage: cgImage)
    return finalImage!
    
  }
}
