//
//  Post.swift
//  instagramHashtag
//
//  Created by Humberto Morales on 7/17/15.
//  Copyright (c) 2015 Humberto Morales. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class Post : NSObject{
    var idPost : String!
    var comments : Comments!
    var created_time : Int!
    var caption : Caption!
    var link : String!
    var tags = [JSON]()
    var likes = [JSON]()
    var type : String!
    var users_in_photo = [JSON]()
    var filter : String!
    var images : Images!
    var user_has_liked : Bool!
    var user : User!
    var attribution : AnyObject
    var location : Location!
    
    override init(){
        self.idPost = nil
        self.comments = nil
        self.created_time = nil
        self.caption = nil
        self.link = nil
        self.tags = []
        self.likes = []
        self.type = nil
        self.users_in_photo = []
        self.filter = nil
        self.images = nil
        self.user_has_liked = nil
        self.user = nil
        self.attribution = []
        self.location = nil
    }
    
    deinit{
        
    }
}

class User : NSObject{
    var username : String!
    var id : String!
    var profile_picture : String!
    var fullName : String!
    var savedProfileImage : UIImage?
}

class Image  : NSObject{
    var url : String!
    var width : Int!
    var height : Int!
    var savedImage : UIImage?
}

class Images : NSObject {
    var low_resolution : Image!
    var stanrd_resolution : Image!
    var thunbnail : Image!
}

class Location : NSObject {
    var id : Int!
    var latitude : Double!
    var name : String!
    var longitude : Double!
}

class Comments  : NSObject {

    var count : Int!
    var data = [JSON]()
}

class Likes  : NSObject{
    var count : Int!
    var data = []
}

class Caption {
    var from : From!
    var id : String!
    var created_time : Int!
    var text : String!
}

class From : User{

}


