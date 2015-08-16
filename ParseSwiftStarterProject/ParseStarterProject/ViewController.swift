//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
  
  lazy var imageQueue = NSOperationQueue()

  //MARK: Constraint Buffer Constants - Open Filter Mode
  let kLeadingImageViewConstraintBuffer : CGFloat = 40
  let kTrailingImageViewConstraintBuffer : CGFloat = 40
  let kTopImageViewConstraintBuffer : CGFloat = 40
  let kBottomImageViewConstraintBuffer : CGFloat = 120
  let kStandardConstraintMargin : CGFloat = 8
  
//MARK: IBOutlets
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var selectButton: UIButton!
  
  //Contraint outlets
  @IBOutlet weak var trailingImageViewConstraint: NSLayoutConstraint!
  @IBOutlet weak var leadingImageViewConstraint: NSLayoutConstraint!
  @IBOutlet weak var topImageViewConstraint: NSLayoutConstraint!
  @IBOutlet weak var bottomImageViewConstraint: NSLayoutConstraint!
  @IBOutlet weak var bottomCollectionViewConstraint: NSLayoutConstraint!
  
//MARK: Variables
  let picker: UIImagePickerController = UIImagePickerController()
  let kThumbnailSize = CGSize(width: 100, height: 100)
  let kPostedImageSize = CGSize(width: 600, height: 600)

  var thumbnail: UIImage!
  let context = FilterService.gpuContextCreation()
  
  var filters: [(UIImage, CIContext) -> (UIImage!)] = [FilterService.instantImageFromOriginalImage, FilterService.monoImageFromOriginalImage, FilterService.transferImageFromOriginalImage]
  
  var displayImage : UIImage! {
    didSet {
      imageView.image = displayImage
      thumbnail = ImageResizer.resizeImage(displayImage, size:kThumbnailSize)
      collectionView.reloadData()
    }
  }
  
  var constraintConstants = [CGFloat]()
  
  let alert = UIAlertController(title: "Photo Filter Selection", message: "Please select Photo or Filter", preferredStyle: UIAlertControllerStyle.ActionSheet)
  
//MARK: Life Cycle methods
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if let image = imageView.image {
      selectButton.setTitle("Select Option", forState: .Normal)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.dataSource = self
    collectionView.delegate = self
    imageView.image = UIImage(named: "placerholder.jpg")
    
//MARK: Alert actions
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert) -> Void in
      println("Selection cancelled")
    }
    
    let photoSelectAction = UIAlertAction(title: "Camera/Photo Library", style: UIAlertActionStyle.Default) { (alert) -> Void in
      self.presentViewController(self.picker, animated: true, completion: nil)
    }
    
    if UIDevice.currentDevice().userInterfaceIdiom != UIUserInterfaceIdiom.Pad {
      let filterAction = UIAlertAction(title: "Filter", style: UIAlertActionStyle.Default) { (alert) -> Void in
        self.enterFilterMode()
      }
      alert.addAction(filterAction)
    }
    
    
    let postAction = UIAlertAction(title: "Post Image", style: UIAlertActionStyle.Default)
      { (alert) -> Void in
      
      let photoObject = PFObject(className: "Photos")
      if let image = self.imageView.image {
        let resizedImage = ImageResizer.resizeImage(image, size: self.kPostedImageSize)
        let data = UIImageJPEGRepresentation(resizedImage, 1.0)
        let file = PFFile(name: "postedImage.jpeg", data: data)
        photoObject["image"] = file
      }

      photoObject.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
        if let error = error {
          switch error.code {
          case PFErrorCode.ErrorInternalServer.rawValue, PFErrorCode.ErrorConnectionFailed.rawValue:
             println("There was a problem with the Parse server, please try again later")
          default:
            println("Your file could not be saved!. Try again later!")
          }
        } else {
          println("Yay, the photo was saved")
        }
        
      })

    }
    
    let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (alert) -> Void in
      self.performSegueWithIdentifier("ShowGallery", sender: self)
    }

    
    
    //adding alert actions
    alert.addAction(cancelAction)
    alert.addAction(photoSelectAction)
    alert.addAction(postAction)
    alert.addAction(galleryAction)
    
    self.picker.delegate = self
    
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
      self.picker.sourceType = UIImagePickerControllerSourceType.Camera
    } else {
      self.picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    }
    
    displayImage = UIImage(named: "placerholder.jpg")
    
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
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowGallery" {
      let controller = segue.destinationViewController as! GalleryViewController
      controller.delegate = self
    }
  }

//MARK: Helper methods
func enterFilterMode() {
  
  //Save off the current values of the constraint constants
  constraintConstants.append(leadingImageViewConstraint.constant)
  constraintConstants.append(trailingImageViewConstraint.constant)
  constraintConstants.append(topImageViewConstraint.constant)
  constraintConstants.append(bottomImageViewConstraint.constant)
  constraintConstants.append(bottomCollectionViewConstraint.constant)
  
  leadingImageViewConstraint.constant = kLeadingImageViewConstraintBuffer
  trailingImageViewConstraint.constant = kTrailingImageViewConstraintBuffer
  topImageViewConstraint.constant = kTopImageViewConstraintBuffer
  bottomImageViewConstraint.constant = kBottomImageViewConstraintBuffer
  bottomCollectionViewConstraint.constant = kStandardConstraintMargin
  
  UIView.animateWithDuration(0.3, animations: { () -> Void in
    self.view.layoutIfNeeded()
  })
  
  let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "closeFilterMode")
  navigationItem.rightBarButtonItem = doneButton
}

func closeFilterMode() {
  
  //Restore the original values of the constraint constants
  leadingImageViewConstraint.constant = constraintConstants[0]
  trailingImageViewConstraint.constant = constraintConstants[1]
  topImageViewConstraint.constant = constraintConstants[2]
  bottomImageViewConstraint.constant = constraintConstants[3]
  bottomCollectionViewConstraint.constant = constraintConstants[4]
  
  navigationItem.rightBarButtonItem = nil
  println("Closing Filter Mode")
}

}



//MARK: UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    let image: UIImage = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
    self.imageView.image = image
    displayImage = image
    self.picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    self.picker.dismissViewControllerAnimated(true, completion: nil)
    println("Picker Cancelled")
  }
  
  
}

//MARK: UICollectionViewDataSource
extension ViewController : UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filters.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
   let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as! ThumbnailCell
    
    let filter = filters[indexPath.row]
    if let thumbnail = thumbnail {
    imageQueue.addOperationWithBlock({ () -> Void in
      if let filteredImage = filter(thumbnail,self.context) {
         NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
           cell.imageView.image = filteredImage
        })
    }
    })
    
  }
  return cell
}
}

extension ViewController: UICollectionViewDelegate {
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as! ThumbnailCell
    
    let filter = filters[indexPath.row]
    imageQueue.addOperationWithBlock({ () -> Void in
      if let filteredImage = filter(self.imageView.image!,self.context) {
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          self.imageView.image = filteredImage
        })
      }
    })
    
  }
  
}

extension ViewController: GalleryViewControllerDelegate {
  
  func galleryViewController(controller: GalleryViewController, didSelectImage image: UIImage) {
      imageView.image = image
      displayImage = image
  }
}
