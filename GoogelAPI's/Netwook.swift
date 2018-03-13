//
//  Netwook.swift
//  GoogelAPI's
//
//  Created by Appinventiv Mac on 13/03/18.
//  Copyright © 2018 Appinventiv Mac. All rights reserved.
//

import Foundation




class Network {
     var dict:[String:[String:Any]]!
    var name,id,vicinity:[String]!
     var rating:[NSNumber]!
     var image:[String]!
     let headers = [
        "Cache-Control": "no-cache",
        "Postman-Token": "f332f7b2-b335-447e-b0a7-fbcc75f69701"
    ]
     fileprivate var key = "AIzaSyBXSZOOoR3kNLHEy1maOLnJzrUoGZRgAIM"
     func getResponce(_ lat:String,_ long:String){
        
        let request = getRequest(lat,long)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        print(lat)
        print(long)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
                
            } else {
                 let httpResponse = response as? HTTPURLResponse
                 print(httpResponse as Any)
                 print(Date())
                
            }
            guard let data = data else {return}
            let v = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any]
            print(v)
            
            let results = v["results"] as! [[String:Any]]
            
            for result in results{
                
                for(key,value) in result
                {
                    if key=="name"
                    {
                        self.name.append(value as! String)
                    }
                    else if key=="place_id"
                    {
                        self.id.append(value as! String)
                    }
                    else if key=="rating"
                    {
                        self.rating.append(value as! NSNumber)
                    }
                    else if key=="vicinity"
                    {
                        self.vicinity.append(value as! String)
                    }
                    else if key == "icon" {
                        self.image.append(value as! String)
                    }
        }
                }
        }).resume()
        
    }
    
     func getRequest(_ lat:String,_ long:String) -> NSMutableURLRequest{
        return NSMutableURLRequest(url: NSURL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(long)&radius=5000&types=food&name=cruise&key=AIzaSyBXSZOOoR3kNLHEy1maOLnJzrUoGZRgAIM")! as URL,
                                   cachePolicy: .useProtocolCachePolicy,
                                   timeoutInterval: 10.0)
    }
    
}


