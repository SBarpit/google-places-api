//
//  Netwook.swift
//  GoogelAPI's
//
//  Created by Arpit Srivastava on 13/03/18.
//  Copyright © 2018 Appinventiv Mac. All rights reserved.
//

import Foundation




class Network {
    
    var mdata:Places?
    var vc:ViewController!
    
    let headers = [
        "Cache-Control": "no-cache",
        "Postman-Token": "f332f7b2-b335-447e-b0a7-fbcc75f69701"
    ]
    
    fileprivate var key = "AIzaSyBXSZOOoR3kNLHEy1maOLnJzrUoGZRgAIM"
    func getResponce(_ Search:String){
        
        
        let request = getRequest(Search)
        
        request.httpMethod = "GET"
        
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if (error != nil) {
                
                print(error as Any)
            }else{
                do {
                    self.mdata =  try JSONDecoder().decode(Places.self, from: data!)
                }
                catch {
                    print("Error")
                }
                
            }
            DispatchQueue.main.async {
                self.vc.tableView.reloadData()
            }
        }).resume()
        
    }
    
    // MARK: Send request to server
    
    func getRequest(_ search:String) -> NSMutableURLRequest{
        return NSMutableURLRequest(url: NSURL(string: "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(search)&key=AIzaSyBatToiKxdUkBLl_pB-COLqUUeEH3UljoY")! as URL,
                                   cachePolicy: .useProtocolCachePolicy,
                                   timeoutInterval: 10.0)
    }
    
}


