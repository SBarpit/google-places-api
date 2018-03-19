//
//  Modal.swift
//  GoogelAPI's
//
//  Created by Appinventiv Mac on 19/03/18.
//  Copyright © 2018 Appinventiv Mac. All rights reserved.
//

import Foundation

struct Places : Decodable {
    
    var results:[results]
    var status:String
    
}

struct results : Decodable {
    
    var formatted_address:String
    var icon:String
    var name:String
    var photos:[photos]
    var rating:Double
    
}

struct photos : Decodable {
    
    var height:Int
    var photo_reference:String
    var width:Int
    
}
