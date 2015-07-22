//
//  TableView.swift
//  
//
//  Created by Humberto Morales on 7/17/15.
//
//


let tag : String = "selfie"
let consumerKey = "9e78ffd27ecc4d0f8ce4c77bf5eacde1"
let consumerSecret = "afb121fb648a46c6b21abef1e3befc0b"
let authorizeUrl = "https://api.instagram.com/oauth/authorize"
let responseType = "token"

import UIKit
import OAuthSwift
import SwiftyJSON

class TableView: UITableViewController {
    
    var postsObjects = [Post]()
    
    var MIN_ID  = 0
    var MAX_ID  = 0
    var next_url = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationItem.title = "#Selfie"
        self.tableView.tableFooterView?.hidden=true
        doAuthInstagram()
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
    //MARK: - Authetication
    
    func doAuthInstagram(){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let oauthswift = OAuth2Swift(
            consumerKey: consumerKey,
            consumerSecret: consumerSecret,
            authorizeUrl: authorizeUrl,
            responseType: responseType)
        
        let state: String = generateStateWithLength(20) as String
        
        oauthswift.authorize_url_handler = WebViewController()
        
        oauthswift.authorizeWithCallbackURL(NSURL(string: "insta-hash://ig9e78ffd27ecc4d0f8ce4c77bf5eacde1")!,
            scope: "likes+comments",
            state: state,
            success: { credential, response, parameters in
                let urlTags : String = "https://api.instagram.com/v1/tags/\(tag)/media/recent?access_token=\(credential.oauth_token)"
                let parameters : Dictionary = ["COUNT":10 , "MIN_TAG_ID" : self.MIN_ID, "MAX_TAG_ID" : self.MAX_ID]
                oauthswift.client.get(urlTags,
                    parameters: parameters,
                    success: { data, response in
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        let json = JSON(data:data)
                        if json["meta"]["code"].intValue == 200 {
                            self.doCreateObjects(json["data"].arrayValue)
                            self.next_url = json["pagination"]["next_url"].stringValue
                            self.MAX_ID = json["pagination"]["next_max_tag_id"].intValue
                            self.MIN_ID = json["pagination"]["min_tag_id"].intValue
                        }
                    },
                    failure: { (error:NSError!) -> Void in
                        print(error)
                })
            },
            failure: {(error:NSError!) -> Void in
                self.log(error.localizedDescription)
        })
    }
    

    
    //MARK: - TableView Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if !self.postsObjects.isEmpty{
            return 1
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !self.postsObjects.isEmpty{
        return self.postsObjects.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> TableViewCell {
        
        var cellIdentifier = ""
        var imageSize = ""
        let post : Post = postsObjects[indexPath.row]

        if indexPath.row % 3 == 0{
            cellIdentifier = "CellBig"
            imageSize = post.images.low_resolution!.url
            
        }else{
            cellIdentifier = "CellSmall"
            imageSize = postsObjects[indexPath.row].images.thunbnail!.url
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TableViewCell
        
        cell.labelUsername.text = post.user.username
        cell.labelText.text = post.caption.text
        cell.labelText.attributedText = highlightHashtags("#\\w+", inString: post.caption.text)
        
        if post.images.low_resolution.savedImage == nil{
            let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: sessionConfiguration)
            let loadDataTask = session.dataTaskWithURL(NSURL(string: imageSize)!, completionHandler: {
                (data:NSData!,response:NSURLResponse!,error:NSError!) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    cell.activity.stopAnimating()
                    if data != nil && error==nil{
                        post.images.low_resolution.savedImage = UIImage(data: data)
                        cell.imageLowRes.image = post.images.low_resolution.savedImage
                    }else{
                        cell.imageLowRes.image = nil
                        print(error.localizedDescription)
                    }
                })
            })
            
            loadDataTask.resume()
        }else{
            cell.imageLowRes.image = post.images.low_resolution.savedImage
        }
        
        let urlsession2 = NSURLSession.sharedSession()
        let loadDataTask2 = urlsession2.dataTaskWithURL(NSURL(string: post.user.profile_picture)!, completionHandler: {
            (data:NSData!,response:NSURLResponse!,error:NSError!) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if data != nil && error==nil{
                    cell.profileImage.image = UIImage(data: data)
                }else{
                    cell.profileImage.image = nil
                    print(error.localizedDescription)
                }
            })
        })
        
        loadDataTask2.resume()

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        if indexPath.row % 3 == 0{
            return 450.0
        }else{
            return 280.0
        }
    }
    
    
    //MARK: - TableView Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sb = self.storyboard?.instantiateViewControllerWithIdentifier("fullImage") as! fullViewController
        sb.post = postsObjects[indexPath.row]
        self.navigationController!.pushViewController(sb, animated:false)
    }
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == tableView.numberOfRowsInSection(indexPath.section)-1{
            loadMoreData()
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    //MARK: - Log
    
    func log(message: String)
    {
        print("[Instagram-Hastag]:\(message)")
        
        
    }
    
    //MARK: - Model
    
    func doCreateObjects(posts: [SwiftyJSON.JSON]){
        for post in posts{
            var actualPost = Post()
            actualPost.idPost = post["id"].stringValue
            actualPost.comments = Comments()
            actualPost.comments.count = post["comments"]["count"].intValue
            actualPost.comments.data = post["comments"]["data"].arrayValue
            actualPost.created_time = post["created_time"].intValue
            actualPost.caption = Caption()
            actualPost.caption.created_time = post["caption"]["created_time"].intValue
            actualPost.caption.text = post["caption"]["text"].stringValue
            actualPost.caption.from = From()
            actualPost.caption.from.username = post["caption"]["from"]["username"].stringValue
            actualPost.caption.from.id = post["caption"]["from"]["id"].stringValue
            actualPost.caption.from.profile_picture = post["caption"]["from"]["profile_picture"].stringValue
            actualPost.caption.from.fullName = post["caption"]["from"]["full_name"].stringValue
            actualPost.link = post["link"].stringValue
            actualPost.tags = post["tags"].arrayValue
            actualPost.likes = post["likes"].arrayValue
            actualPost.type = post["type"].stringValue
            actualPost.users_in_photo = post["users_in_photo"].arrayValue
            actualPost.location = Location()
            actualPost.location.id = post["location"]["id"].intValue
            actualPost.location.latitude = post["location"]["latitude"].doubleValue
            actualPost.location.longitude = post["location"]["longitude"].doubleValue
            actualPost.location.name = post["location"]["name"].stringValue
            actualPost.filter = post["filter"].stringValue
            actualPost.images = Images()
            actualPost.images.low_resolution = Image()
            actualPost.images.low_resolution.url = post["images"]["low_resolution"]["url"].stringValue
            actualPost.images.stanrd_resolution = Image()
            actualPost.images.stanrd_resolution.url = post["images"]["standard_resolution"]["url"].stringValue
            actualPost.images.thunbnail = Image()
            actualPost.images.thunbnail.url = post["images"]["thumbnail"]["url"].stringValue
            actualPost.user_has_liked = post["user_has_liked"].boolValue
            actualPost.user = User()
            actualPost.user.username = post["caption"]["from"]["username"].stringValue
            actualPost.user.id = post["caption"]["from"]["id"].stringValue
            actualPost.user.profile_picture = post["caption"]["from"]["profile_picture"].stringValue
            actualPost.user.fullName = post["caption"]["from"]["full_name"].stringValue
            actualPost.attribution = post["attribution"].object
            
            postsObjects.append(actualPost)
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            self.tableView.flashScrollIndicators()
        })
    }
    
    func loadMoreData(){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let oauthswift = OAuth2Swift(
            consumerKey: consumerKey,
            consumerSecret: consumerSecret,
            authorizeUrl: authorizeUrl,
            responseType: responseType)
        
        let state: String = generateStateWithLength(20) as String
        let parameters : Dictionary = ["COUNT":10 , "MIN_TAG_ID" : self.MIN_ID, "MAX_TAG_ID" : self.MAX_ID]
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
        dispatch_async(queue, {
            oauthswift.client.get(self.next_url,
                parameters: parameters,
                success: { data, response in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    let json = JSON(data:data)
                    if json["meta"]["code"].intValue == 200 {
                        self.doCreateObjects(json["data"].arrayValue)
                        self.next_url = json["pagination"]["next_url"].stringValue
                        self.MAX_ID = json["pagination"]["next_max_tag_id"].intValue
                        self.MIN_ID = json["pagination"]["min_tag_id"].intValue
                    }
                },
                failure: { (error:NSError!) -> Void in
                    print(error)
            })
        })
    }
    
    func listMatches(pattern: String, inString string:String) -> [String]{
        let regex = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.allZeros, error:nil)
        let range = NSMakeRange(0, count(string))
        let matches = regex?.matchesInString(string, options: .allZeros, range: range) as! [NSTextCheckingResult]
        
        return matches.map{
            let range = $0.range
            return (string as NSString).substringWithRange(range)
        }
    }
    
    func highlightHashtags (pattern : String, inString string: String) -> NSAttributedString{
        let regex = NSRegularExpression(pattern: pattern, options: .allZeros, error: nil)
        let range = NSMakeRange(0, count(string))
        let matches = regex?.matchesInString(string, options: .allZeros, range: range) as! [NSTextCheckingResult]
        
        let attributedText = NSMutableAttributedString(string: string)
        
        for match in matches{
            attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: match.range)
        }
        
        return attributedText.copy() as! NSAttributedString
    }
    
    func replaceMatches(pattern:String, inString string: String, withString replacementString: String) -> String?
    {
        let regex = NSRegularExpression(pattern: pattern, options: .allZeros, error: nil)
        let range = NSMakeRange(0, count(string))
        
        return regex?.stringByReplacingMatchesInString(string, options: .allZeros, range: range, withTemplate: replacementString)
    }
    
}
