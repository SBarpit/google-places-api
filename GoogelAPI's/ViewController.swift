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
    
    
    //MARK: IBOutlets
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBox: UITextField!
    
    //MARK: Arrays to store data
    
    var desc:[String] = []
    let pickerView = UIPickerView()

    var name:[String]=[]
    var address:[String]=[]
    var rating:[NSNumber]=[]
    var imageURLS:[String]=[]
    
    
    let headers = [
        "Cache-Control": "no-cache",
        "Postman-Token": "f332f7b2-b335-447e-b0a7-fbcc75f69701"
    ]
    
    //MARK: API key
    
    fileprivate var key = "AIzaSyBXSZOOoR3kNLHEy1maOLnJzrUoGZRgAIM"
    
    //IBAction for search items
    
    @IBAction func searchButton(_ sender: UIButton) {
        sender.flash()
        searchBox.resignFirstResponder()
        let querry = self.searchBox.text
        let newString = querry?.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        self.getResponce(newString!)
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.loadViews()
        pickerView.delegate = self
        searchBox.inputView = pickerView
        searchBox.addTarget(self, action: #selector(responcePredict), for: .editingChanged)
        self.pickerView.reloadAllComponents()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadViews(){
        tableView.dataSource=self
        tableView.delegate=self
        searchBox.delegate = self
        self.shadowView.layer.shadowOffset = CGSize(width: 35, height: 35)
        self.shadowView.layer.shadowColor = UIColor.black.cgColor
        self.shadowView.layer.opacity = 0.9
        self.shadowView.layer.cornerRadius = 8
        self.shadowView.layer.masksToBounds = false
    }
    
    @objc func responcePredict(){
        desc = []
        getResponcePredict(searchBox.text!)
    }
}


//MARK: Extension for tableview delegate nad datasource methods

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
        
        if rating.count < name.count {
            
            cell?.ratingLB.isHidden = true
            
        }else{
            
            cell?.ratingLB.isHidden = false
            
            cell?.ratingLB.text = "\(self.rating[indexPath.row]) ⭐"
            
        }
        
        cell?.vicinityLB.text = self.address[indexPath.row]
        
        cell?.imageView?.downloadedFrom(link: imageURLS[indexPath.row])
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        let transform = CATransform3DTranslate(CATransform3DIdentity, -250, 20, 50)
        cell.layer.transform = transform
        UIView.animate(withDuration:0.6) {
            cell.alpha = 1.0
            cell.layer.transform = CATransform3DIdentity
        }
        
    }
    
}

// MARK: Network Controller,  to make GET request and store data by parsing it into JSON

extension ViewController{
    
    // MARK: Method to get responce from the request
    
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
            
            let status = v["status"] as! String
            
            if status != "ZERO_RESULTS"{
                
                for result in results{
                    
                    for(key,value) in result
                    {
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
            }else{
                self.displayAlertMessage("No results found ! 😅")
            }
            self.tableView.reloadData()
            UIViewController.removeSpinner(spinner: sv)
            
        }).resume()
        
    }
    
    // MARK: Send request to server
    
    func getRequest(_ search:String) -> NSMutableURLRequest{
        return NSMutableURLRequest(url: NSURL(string: "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(search)&key=AIzaSyBatToiKxdUkBLl_pB-COLqUUeEH3UljoY")! as URL,
                                   cachePolicy: .useProtocolCachePolicy,
                                   timeoutInterval: 10.0)
    }
}


// MARK: Add a loader for wating period

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



// MARK: Extension to download images from the url



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



extension UIButton{
    
    func flash(){
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.5
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 3
        layer.add(flash, forKey: nil)
    }
}



extension ViewController:UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (self.searchBox.text?.isEmpty)! {
            self.displayAlertMessage("Can't be empty")
            return
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.name = []
        self.address = []
        self.rating = []
        self.imageURLS = []
        tableView.reloadData()
    }
    
    func displayAlertMessage(_ messageToDisplay: String)
    {
        let alertController = UIAlertController(title: "Alert!", message: messageToDisplay, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            print("Ok button tapped") }
        alertController.addAction(OKAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
}

extension ViewController:UIPickerViewDataSource, UIPickerViewDelegate{
    
    func getResponcePredict(_ Search:String){
        
        let request = getRequestPredict(Search)
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
            
            let results = v["predictions"] as! [[String:Any]]
            
            let status = v["status"] as! String
            
            if status != "ZERO_RESULTS"{
                
                for result in results{
                    
                    for(key,value) in result
                    {
                        if key=="description"
                        {
                            self.desc.append(value as! String)
                            self.pickerView.reloadAllComponents()
                        }
                        
                    }
                }
                
            }else{
                print("No results found ! 😅")
            }
            
        }).resume()
        
    }
    
    func getRequestPredict(_ search:String) -> NSMutableURLRequest{
        print(search)
        let newString = search.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        return NSMutableURLRequest(url: NSURL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(newString)&types=geocode&language=en&key=AIzaSyBatToiKxdUkBLl_pB-COLqUUeEH3UljoY")! as URL,
                                   cachePolicy: .useProtocolCachePolicy,
                                   timeoutInterval: 10.0)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return desc.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return desc[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        searchBox.text = desc[row]
    }
    
}


