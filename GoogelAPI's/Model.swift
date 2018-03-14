//
//  Model.swift
//  GoogelAPI's
//
//  Created by Appinventiv Mac on 14/03/18.
//  Copyright © 2018 Appinventiv Mac. All rights reserved.
//

import Foundation
class Model {
    
    var name:[String]=[]
    var address:[String]=[]
    var rating:[NSNumber]=[]
    var imageURLS:[String]=[]
    
    init(_ json: [[String:Any]]){
        for result in json{
            for(key,value) in result{
                if key=="name"
                {
                    self.name.append(value as! String)
                }
                else if key == "rating"
                {
                    self.rating.append(value as! NSNumber)
                }
                else if key=="formatted_address"
                {
                    self.address.append(value as! String)
                }
                else if key == "icon"
                {
                    self.imageURLS.append(value as! String)
                }
            }
            
        }
    }
}
