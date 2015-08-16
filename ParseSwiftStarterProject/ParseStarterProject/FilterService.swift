//
//  FilterService.swift
//  ParseStarterProject
//
//  Created by Joey Nessif on 8/11/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class FilterService {
  
  class func instantImageFromOriginalImage(image: UIImage, context: CIContext) -> UIImage {
    let image = CIImage(image: image)
    let photoFilter = CIFilter(name: "CIPhotoEffectInstant")
    photoFilter.setValue(image, forKey: kCIInputImageKey)
    return applyFilter(photoFilter, context: context)
  }
  
  class func monoImageFromOriginalImage(image: UIImage, context: CIContext) -> UIImage {
    let image = CIImage(image: image)
    let photoFilter = CIFilter(name: "CIPhotoEffectMono")
    photoFilter.setValue(image, forKey: kCIInputImageKey)
    return applyFilter(photoFilter, context: context)
  }
  
  class func transferImageFromOriginalImage(image: UIImage, context: CIContext) -> UIImage {
    let image = CIImage(image: image)
    let photoFilter = CIFilter(name: "CIPhotoEffectTransfer")
    photoFilter.setValue(image, forKey: kCIInputImageKey)
    return applyFilter(photoFilter, context: context)
  }

  private class func applyFilter(filter: CIFilter, context: CIContext) -> UIImage {
    let outputImage = filter.outputImage
    let extent = outputImage.extent()
    let cgImage = context.createCGImage(outputImage, fromRect: extent)
    let finalImage = UIImage(CGImage: cgImage)
    return finalImage!
  }
    
  class func gpuContextCreation() -> CIContext {
    //gpu context
    let options = [kCIContextWorkingColorSpace : NSNull()]
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    let gpuContext = CIContext(EAGLContext: eaglContext, options: options)
    return gpuContext
  }
  
}
