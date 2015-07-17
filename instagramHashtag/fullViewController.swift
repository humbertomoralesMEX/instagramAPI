//
//  fullViewController.swift
//  
//
//  Created by Humberto Morales on 7/17/15.
//
//

import UIKit

class fullViewController: UIViewController {
    
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var post : Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
            let queue = NSOperationQueue()
            NSURLConnection.sendAsynchronousRequest(
                NSURLRequest(URL: NSURL(string: post.images.stanrd_resolution.url)!),
                queue: queue,
                completionHandler: {
                    (response:NSURLResponse!, data:NSData!, error:NSError!) in
                    dispatch_sync(dispatch_get_main_queue()){
                        self.activity.stopAnimating()
                        if data.length > 0 && error == nil{
                            self.imageView.image = UIImage(data: data)
                        }else if error != nil{
                            self.imageView.image = nil
                        }
                    }
            })
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.navigationController?.popToRootViewControllerAnimated(false)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func exit(sender: AnyObject) {
            self.navigationController?.popToRootViewControllerAnimated(false)
    }

}
