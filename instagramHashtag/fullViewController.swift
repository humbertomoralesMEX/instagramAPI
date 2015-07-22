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
    
    @IBOutlet var longPressGesture: UILongPressGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        self.labeLikes.text = "❤︎ "+post.likes.count.description+" likes"
        self.labelText.text = post.caption.text
        self.labelText.numberOfLines = 2
        self.labelText.adjustsFontSizeToFitWidth = true
        self.labelText.minimumScaleFactor = 0.8
        
        let session = NSURLSession.sharedSession()
        let urlImage = NSURL(string: post.images.stanrd_resolution.url)!
        let sessionTask = session.dataTaskWithURL(urlImage, completionHandler: {
            (data:NSData!,response:NSURLResponse!,error:NSError!) -> Void in
            dispatch_sync(dispatch_get_main_queue()){
                self.activity.stopAnimating()
                if data.length > 0 && error == nil{
                    self.imageView.image = UIImage(data: data)
                }else if error != nil{
                    self.imageView.image = nil
                }
            }
        })
        
        sessionTask.resume()
        
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 3.0
    }
    
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func exit(sender: AnyObject) {
            self.navigationController?.popToRootViewControllerAnimated(false)
    }

    //MARK: - UIViewScrollDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    //MARK: - Save Image with long press gesture = 1.2 sec
    
    @IBAction func handleLongPress(sender: UILongPressGestureRecognizer) {
        var controller:UIAlertController?
        controller = UIAlertController(title: "Do you want save the image?", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let actionSave = UIAlertAction(title: "Save Photo", style: UIAlertActionStyle.Default,
            handler: {(paramAction:UIAlertAction!) in
                let selectorAsString = "imageWasSavedSuccessfully:didFinishSavingWithError:context:"
                let selectorToCall = Selector(selectorAsString)
                UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, selectorToCall, nil)
            })
        let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil)
        controller?.addAction(actionSave)
        controller?.addAction(actionCancel)
        self.presentViewController(controller!, animated: true, completion: nil)
    }
    
    func imageWasSavedSuccessfully(image: UIImage, didFinishSavingWithError error: NSError!, context: UnsafeMutablePointer<()>){
            if let theError = error{
            println("An error happened while saving the image = \(theError)")
        }else{
            println("Image was saved successfully")
    } }
    
}
