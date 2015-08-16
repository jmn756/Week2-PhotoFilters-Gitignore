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
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
      
      let query = PFQuery(className: "Post")
      
      query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
        if let error = error {
          println(error.localizedDescription)
        } else if let posts = results as? [PFObject] {
          println(posts.count)
          for post in posts {
            if let imageFile = post["image"] as? PFFile {
              imageFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if let error = error {
                  println(error.localizedDescription)
                } else if let data = data,
                  image = UIImage(data: data){
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                      let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
                      self.view.addSubview(imageView)
                      imageView.image = image
                    })
                }
              })
            }
          }
        }
      }

    }

}

extension TimeLineViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCellWithIdentifier("timelineCell", forIndexPath: indexPath) as! UITableViewCell
    
    return cell
  }
}
