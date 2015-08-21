//
//  GalleryViewController.swift
//  ParseStarterProject
//
//  Created by Joey Nessif on 8/16/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Photos

protocol GalleryViewControllerDelegate : class {
  func galleryViewController(controller: GalleryViewController, didSelectImage image: UIImage)
}

class GalleryViewController: UIViewController {

  lazy var imageQueue = NSOperationQueue()
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  var fetchResult : PHFetchResult!
  let cellSize = CGSize(width: 100, height: 100)
  var desiredFinalImageSize : CGSize!
  var startingScale : CGFloat = 0
  var scale : CGFloat = 0
  
  weak var delegate : GalleryViewControllerDelegate?
  
  
    override func viewDidLoad() {
        super.viewDidLoad()

      fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
      
      collectionView.dataSource = self
      collectionView.delegate = self
      
      let pinchGesture = UIPinchGestureRecognizer(target: self, action: "pinchRecognized:")
      collectionView.addGestureRecognizer(pinchGesture)
      
    }

  func pinchRecognized(pinch : UIPinchGestureRecognizer) {
    //println(pinch.scale)
    
    if pinch.state == UIGestureRecognizerState.Began {
      println("began!")
      startingScale = pinch.scale
    }
    
    if pinch.state == UIGestureRecognizerState.Changed {
      println("changed!")
    }
    
    if pinch.state == UIGestureRecognizerState.Ended {
      println("ended!")
       NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          self.scale = self.startingScale * pinch.scale
          let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
          let newSize = CGSize(width: layout.itemSize.width * self.scale, height: layout.itemSize.height * self.scale)
          self.collectionView.performBatchUpdates({ () -> Void in
            layout.itemSize = newSize
            layout.invalidateLayout()
           }, completion: nil )
        })
    }
  }
  
}


//MARK: UICollectionViewDataSource
extension GalleryViewController : UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return fetchResult.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as! ThumbnailCell
   
    if let asset = fetchResult[indexPath.row] as? PHAsset {
      imageQueue.addOperationWithBlock({ () -> Void in

      PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: cellSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
        
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        if let image = image {
          cell.imageView.image = image
        }
        })
      }
      })
    }
    return cell
  }
}

//MARK: UICollectionViewDelegate
extension GalleryViewController : UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    
    let options = PHImageRequestOptions()
    options.synchronous = true
    
    if let asset = fetchResult[indexPath.row] as? PHAsset {
      imageQueue.addOperationWithBlock({ () -> Void in
        
        PHCachingImageManager.defaultManager().requestImageForAsset(asset, targetSize: desiredFinalImageSize, contentMode: PHImageContentMode.AspectFill, options: options) { (image, info) -> Void in
          

          NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            if let image = image {
              self.delegate?.galleryViewController(self, didSelectImage: image)
              self.navigationController?.popViewControllerAnimated(true)
            }
          })
        }
      })

  }

}
}
