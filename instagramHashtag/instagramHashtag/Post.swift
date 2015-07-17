//
//  Post.swift
//  instagramHashtag
//
//  Created by Humberto Morales on 7/17/15.
//  Copyright (c) 2015 Humberto Morales. All rights reserved.
//

import Foundation
import SwiftyJSON

class Post {
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
    
    init(){
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

class User {
    var username : String!
    var id : String!
    var profile_picture : String!
    var fullName : String!
}

class Image {
    var url : String!
    var width : Int!
    var height : Int!
}

class Images {
    var low_resolution : Image!
    var stanrd_resolution : Image!
    var thunbnail : Image!
}

class Location {
    var id : Int!
    var latitude : Double!
    var name : String!
    var longitude : Double!
}

class Comments {

    var count : Int!
    var data = [JSON]()
}

class Likes {
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


