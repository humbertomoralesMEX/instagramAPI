//
//  TableView.swift
//  
//
//  Created by Humberto Morales on 7/17/15.
//
//


let tag : String = "selfie"

import UIKit
import OAuthSwift
import SwiftyJSON

class TableView: UITableViewController {
    
    var postsObjects = [Post]()
    
    var MIN_ID : Int!
    var MAX_ID : Int!
    var next_url = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationItem.title = "#Selfie"
        self.tableView.tableFooterView?.hidden=true
        doAuthInstagram()
    }
    
    //MARK: - Authetication
    
    func doAuthInstagram(){
        let oauthswift = OAuth2Swift(
            consumerKey: "9e78ffd27ecc4d0f8ce4c77bf5eacde1",
            consumerSecret: "afb121fb648a46c6b21abef1e3befc0b",
            authorizeUrl: "https://api.instagram.com/oauth/authorize",
            responseType: "token")
        
        let state: String = generateStateWithLength(20) as String
        
        oauthswift.authorize_url_handler = WebViewController()
        
        oauthswift.authorizeWithCallbackURL(NSURL(string: "insta-hash://ig9e78ffd27ecc4d0f8ce4c77bf5eacde1")!,
            scope: "likes+comments",
            state: state,
            success: { credential, response, parameters in
                let urlTags : String = "https://api.instagram.com/v1/tags/\(tag)/media/recent?access_token=\(credential.oauth_token)"
                let parameters : Dictionary = ["COUNT":10 , "MIN_TAG_ID" : 0, "MAX_TAG_ID" : 0]
                oauthswift.client.get(urlTags,
                    parameters: parameters,
                    success: { data, response in
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
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postsObjects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cellIdentifier = ""
        var imageSize = ""

        if indexPath.row % 3 == 0{
            cellIdentifier = "CellBig"
            imageSize = postsObjects[indexPath.row].images.low_resolution!.url
            
        }else{
            cellIdentifier = "CellSmall"
            imageSize = postsObjects[indexPath.row].images.thunbnail!.url
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TableViewCell
        
        cell.labelUsername.text = postsObjects[indexPath.row].user.username
        cell.labelText.text = postsObjects[indexPath.row].caption.text
        
        let queue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(
            NSURLRequest(URL: NSURL(string: postsObjects[indexPath.row].user.profile_picture)!),
            queue: queue,
            completionHandler: {
                (response:NSURLResponse!, data:NSData!, error:NSError!) in
                dispatch_sync(dispatch_get_main_queue()){
                    if data.length > 0 && error == nil{
                        cell.profileImage.image = UIImage(data: data)
                    }else if error != nil{
                        cell.profileImage.image = nil
                    }
                }
        })
        
        let queue2 = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(
            NSURLRequest(URL: NSURL(string: imageSize)!),
            queue: queue2,
            completionHandler: {
                (response:NSURLResponse!, data:NSData!, error:NSError!) in
                dispatch_sync(dispatch_get_main_queue()){
                    cell.activity.stopAnimating()
                    if data.length > 0 && error == nil{
                        cell.imageLowRes.image = UIImage(data: data)
                    }else if error != nil{
                        cell.imageLowRes.image = nil
                    }
                }
        })
        
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
        self.tableView.reloadData()
        self.tableView.flashScrollIndicators()
    }
    
    func loadMoreData(){
        let oauthswift = OAuth2Swift(
            consumerKey: "9e78ffd27ecc4d0f8ce4c77bf5eacde1",
            consumerSecret: "afb121fb648a46c6b21abef1e3befc0b",
            authorizeUrl: "https://api.instagram.com/oauth/authorize",
            responseType: "token")
        
        let state: String = generateStateWithLength(20) as String
        let parameters : Dictionary = ["COUNT":10 , "MIN_TAG_ID" : self.MIN_ID, "MAX_TAG_ID" : self.MAX_ID]
                oauthswift.client.get(next_url,
                    parameters: parameters,
                    success: { data, response in
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
    }

}
