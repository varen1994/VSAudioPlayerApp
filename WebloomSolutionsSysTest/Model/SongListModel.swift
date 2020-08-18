//
//  SongListModel.swift
//  WebloomSolutionsSysTest
//
//  Created by Varender Singh on 17/08/20.
//  Copyright © 2020 Varender. All rights reserved.
//

import UIKit

class SongListModel: Codable {
    var count:Int?
    var previous:Int?
    var results:[SingleSong]?
}

class SingleSong:Codable {
    var id:Int?
    var name:String?
    var url:String?
    var thumbnail:String?
    var artist:String?
    var isHidden:Bool?
    var isActive:Bool?
    var userActions:Bool?
    var createdAt:String?
    var updatedAt:String?
    var category:Category?
}

class Category:Codable {
    var id:Int?
    var uuid:String?
    var name:String?
    var icon:String?
}
