//
//  TimeLineViewController.swift
//  ParseStarterProject
//
//  Created by Joey Nessif on 8/16/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class TimeLineViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  
  var images = [UIImage]()
  var createdDate = NSDate()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Timeline Photos"
    tableView.dataSource = self
    let query = PFQuery(className: "Photos")
    
    query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
      if let error = error {
        println(error.localizedDescription)
      } else {
        if let photos = results as? [PFObject] {
          for photo in photos {
             self.createdDate = photo.createdAt!
             if let imageFile = photo["image"] as? PFFile {
              imageFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if let error = error {
                  println(error.localizedDescription)
                } else if let data = data,
                  image = UIImage(data: data) {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                      self.images.append(image)
                      self.tableView.reloadData()
                    })
                }
              })
            }
          }
        }
      }
      
    }
  }
}


extension TimeLineViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return images.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCellWithIdentifier("timelineCell", forIndexPath: indexPath) as! TimelineTableViewCell
    
    cell.parseImage.image = images[indexPath.row]
    cell.createdLabel.text = "Created: \(createdDate)"
    
    return cell
  }
}
