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
    
    
    var mdata:Places!
    
    //MARK: IBOutlets
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBox: UITextField!
    
    var network:Network!
    
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
//        network = Network()
//        network.vc = self
        self.getResponce(newString!)
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.loadViews()
        
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
    
   
}


//MARK: Extension for tableview delegate nad datasource methods

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mdata == nil {
            return 0
        }else{
            print(self.mdata.results.count)
             return self.mdata.results.count
        }
       
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowCell", for: indexPath) as? ShowCell
        
        cell?.nameLB.text = self.mdata.results[indexPath.row].name
        
        if self.mdata.results.count < indexPath.row {
            
            cell?.ratingLB.isHidden = true
            
        }else{
            
            cell?.ratingLB.isHidden = false
            
            cell?.ratingLB.text = "\(self.mdata.results[indexPath.row].rating) ⭐"
            
        }
        
        cell?.vicinityLB.text = self.mdata.results[indexPath.row].formatted_address
        
        let ref = self.mdata.results[indexPath.row].photos[0].photo_reference
        let width = self.mdata.results[indexPath.row].photos[0].width
        let url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=134&photoreference=\(ref)&key=AIzaSyBXSZOOoR3kNLHEy1maOLnJzrUoGZRgAIM"
        cell?.imageView?.downloadedFrom(link: url)
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
            }else{
                do {
                    self.mdata =  try JSONDecoder().decode(Places.self, from: data!)
                    print(self.mdata.results.count)
                }
                catch {
                    print("Error")
                }

            }
            DispatchQueue.main.async {
                 self.tableView.reloadData()
            }

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


