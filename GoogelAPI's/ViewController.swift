//
//  ViewController.swift
//  GoogelAPI's
//
//  Created by Appinventiv Mac on 13/03/18.
//  Copyright © 2018 Appinventiv Mac. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBox: UITextField!
    
    
    var name:[String]=[]
    var address:[String]=[]
    var rating:[NSNumber]=[]
    var imageURLS:[String]=[]
    
    
    let headers = [
        "Cache-Control": "no-cache",
        "Postman-Token": "f332f7b2-b335-447e-b0a7-fbcc75f69701"
    ]
    
    fileprivate var key = "AIzaSyBXSZOOoR3kNLHEy1maOLnJzrUoGZRgAIM"
    
    
    @IBAction func searchButton(_ sender: UIButton) {
        self.loadViews()
        tableView.isHidden = false
        let querry = self.searchBox.text
        let newString = querry?.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        self.getResponce(newString!)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shadowView.layer.shadowOffset = CGSize(width: 5, height: 5)
        shadowView.layer.shadowColor = UIColor.blue.cgColor
        self.shadowView.layer.opacity = 0.7
        self.shadowView.layer.cornerRadius = 8
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadViews(){
        tableView.dataSource=self
        tableView.delegate=self
    }
    
}


extension ViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.name.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowCell", for: indexPath) as? ShowCell
        cell?.nameLB.text = self.name[indexPath.row]
        cell?.ratingLB.text = "\(self.rating[indexPath.row])"
        cell?.vicinityLB.text = self.address[indexPath.row]
        cell?.imageView?.downloadedFrom(link: imageURLS[indexPath.row])
        return cell!
    }
}


extension ViewController{
    
    func getResponce(_ Search:String){
        let sv = UIViewController.displaySpinner(onView: self.view)
        let request = getRequest(Search)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
                
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse as Any)
                
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
                    else if key == "rating"{
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
            UIViewController.removeSpinner(spinner: sv)
        }).resume()
        
    }
    
    func getRequest(_ search:String) -> NSMutableURLRequest{
        return NSMutableURLRequest(url: NSURL(string: "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(search)&key=AIzaSyBXSZOOoR3kNLHEy1maOLnJzrUoGZRgAIM")! as URL,
                                   cachePolicy: .useProtocolCachePolicy,
                                   timeoutInterval: 10.0)
    }
}



extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { 
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}


