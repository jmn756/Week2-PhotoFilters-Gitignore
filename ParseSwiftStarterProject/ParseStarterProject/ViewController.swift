//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

//MARK: IBOutlets
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var selectButton: UIButton!
  
//MARK: Variables
  var filterAction = [UIAlertAction]()
  let picker: UIImagePickerController = UIImagePickerController()
  let cgWidth = 600
  let cgHeight = 600
  //var filters: [(UIImage, CIContext) -> (UIImage!)] = [FilterService.applyFilter(<#image: UIImage#>, filter: <#String#>)]
  
  let alert = UIAlertController(title: "Photo Filter Selection", message: "Please select Photo or Filter", preferredStyle: UIAlertControllerStyle.ActionSheet)
  
//MARK: LifeCycle functions
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if let image = imageView.image {
      selectButton.setTitle("Select Filter", forState: .Normal)
      
      //enabling filters and post actions, since an image has been selected
      for item in filterAction {
          item.enabled = true
        }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
      println("Selection cancelled")
    }
    
    let photoSelectAction = UIAlertAction(title: "Camera/Photo Library", style: UIAlertActionStyle.Default) { (alert) -> Void in
      self.presentViewController(self.picker, animated: true, completion: nil)
    }
    
    let instantEffectAction = UIAlertAction(title: "Instant Filter", style: UIAlertActionStyle.Default) { (alert) -> Void in
      
      let photoFilter = "CIPhotoEffectInstant"
      self.imageView.image = FilterService.applyFilter(self.imageView.image!, filter: photoFilter)
      
    }
    
    let monoEffectAction = UIAlertAction(title: "Mono Filter", style: UIAlertActionStyle.Default) { (alert) -> Void in
      
      let photoFilter = "CIPhotoEffectMono"
      self.imageView.image = FilterService.applyFilter(self.imageView.image!, filter: photoFilter)
  
      
    }
    
    let transferEffectAction = UIAlertAction(title: "Transfer Filter", style: UIAlertActionStyle.Default) { (alert) -> Void in
      
      let photoFilter = "CIPhotoEffectTransfer"
      self.imageView.image = FilterService.applyFilter(self.imageView.image!, filter: photoFilter)
      
    }
    
    let postAction = UIAlertAction(title: "Post Image", style: UIAlertActionStyle.Default)
      { (alert) -> Void in
      
      let photoObject = PFObject(className: "Photos")
      let size = CGSize(width: self.cgWidth, height: self.cgHeight)
      if let image = self.imageView.image {
        let resizedImage = ImageResizer.resizeImage(image, size: size)
        let data = UIImageJPEGRepresentation(resizedImage, 1.0)
        let file = PFFile(name: "postedImage.jpeg", data: data)
        photoObject["image"] = file
      }

      photoObject.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
        if let error = error {
          println("There was an error saving your photo to Parse")
        } else {
          println("Yay, the photo was saved")
        }
        
      })

    }
    
    filterAction.insert(instantEffectAction, atIndex: 0)
    filterAction.insert(monoEffectAction, atIndex: 1)
    filterAction.insert(transferEffectAction, atIndex: 2)
    filterAction.insert(postAction, atIndex: 3)
    
    //disabling filter and post actions until an image has been selected
    for item in filterAction {
      item.enabled = false
    }
    
    //adding alert actions
    alert.addAction(cancelAction)
    alert.addAction(photoSelectAction)
    alert.addAction(instantEffectAction)
    alert.addAction(monoEffectAction)
    alert.addAction(transferEffectAction)
    alert.addAction(postAction)
    
    self.picker.delegate = self
    
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
      self.picker.sourceType = UIImagePickerControllerSourceType.Camera
    } else {
      self.picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    }
    
  }

//MARK: IBActions
  @IBAction func buttonPressed(sender: UIButton) {
    
    alert.modalPresentationStyle = UIModalPresentationStyle.Popover
    
    if let popover = alert.popoverPresentationController {
      popover.sourceView = view
      popover.sourceRect = selectButton.frame
    }
    self.presentViewController(alert, animated: true, completion: nil)
    
  }
  
}

//Sample code below
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    let image: UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
    self.imageView.image = image
    self.picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    self.picker.dismissViewControllerAnimated(true, completion: nil)
    println("Picker Cancelled")
  }
  
  
}
