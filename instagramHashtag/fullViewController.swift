//
//  fullViewController.swift
//  
//
//  Created by Humberto Morales on 7/17/15.
//
//

import UIKit

class fullViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var labeLikes: UILabel!
    var post : Post!
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        self.labeLikes.text = "❤︎ "+post.likes.count.description+" likes"
        self.labelText.text = post.caption.text
        self.labelText.numberOfLines = 2
        self.labelText.adjustsFontSizeToFitWidth = true
        self.labelText.minimumScaleFactor = 0.8
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
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 3.0
    }
    
/*    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.navigationController?.popToRootViewControllerAnimated(false)
    }*/
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func exit(sender: AnyObject) {
            self.navigationController?.popToRootViewControllerAnimated(false)
    }

    //MARK: - UIViewScrollDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView!) {
        
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
}
