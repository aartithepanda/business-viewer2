//
//  ViewController.swift
//  iDev Business Viewer
//
//  Created by Siraj Zaneer on 12/25/16.
//  Copyright © 2016 Siraj Zaneer. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ViewController: UIViewController {

    var token: String? = nil //Stores apps temporary "token" to tell server that yeah this device has permission to use the api
    
    let baseUrl = "https://api.yelp.com/oauth2/token" //Url for getting access
    let grant_type = "client_credentials" //A paramter that tells the server we want access for "client"
    let client_id = "b5IWJOAwIKwyOsOGbS-sCA" //App specific information so server know who is requesting and for what. Put your id here.
    let client_secret = "vfXApOXb22emM3R0VBf2fnn2KTz7fuQJwAj00NbumxZ2YKldGvdEYOfgDZ0UNRqS" //Pretty much same as previous but put your secret
    
    
    let searchURL = "https://api.yelp.com/v3/businesses/search" //Url for searching for things
    let location = "San Francisco,CA" //Some location
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getToken()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getToken() {
        /*
         This part looks like a lot of code but really what the first parameter is is just the url, the second is the method which type of request we are making which is a "POST" request which tells the server that we are sending information (clien id and secret) rather than asking for some, the third is parameters which are the information we are sending the server, the fourth is encoding which is the format in which we are sending the information, and then headers are nil because we don't have any. Then once we send the request the server sends back some information which we store in "response".
         */
        Alamofire.request(baseUrl, method: .post, parameters: ["grant_type" : grant_type, "client_id" : client_id, "client_secret" : client_secret], encoding: URLEncoding.default, headers: nil).validate().responseJSON { response in
            
            // This part does different things based on whether or not it was successful
            switch response.result.isSuccess {
            case true:
                if let value = response.result.value {
                    let info = JSON(value) //Since it was successful we store it in a JSON object
                    
                    self.token = info["access_token"].stringValue //Store it into the token variable so we can use it later on to tell the server we already have access to it!
                    
                    self.loadBusiness()
                }
            case false:
                print(response.result.error?.localizedDescription ?? "error")
            }
            
        }

    }
    
    func loadBusiness() {
        /*
         By now I think you kinda get the gist of how the request works but the one major difference here is that we now have parameters in the header which in  our case is the token! This tells Yelp that we have been granted access and the token is our password to get into the Yelp club :D!
         */
        Alamofire.request(searchURL, method: .get, parameters: ["location" : location], encoding: URLEncoding.default, headers: ["Authorization" : "Bearer \(token!)"]).validate().responseJSON { response in
            // This part does different things based on whether or not it was successfull
            switch response.result.isSuccess {
            case true:
                if let value = response.result.value {
                    let info = JSON(value) //Since it was successful we store it in a JSON object
                    
                    let businesses = info["businesses"].arrayValue //Store the businesses
                    
                    let business = businesses[0]
                    
                    self.nameLabel.text = business["name"].stringValue
                    
                    self.phoneLabel.text = business["phone"].stringValue
                    
                    self.priceLabel.text = business["price"].stringValue
                    
                    self.locationLabel.text = "\(business["location"]["address1"].stringValue), \(business["location"]["city"].stringValue)"
                    
                    let imageUrl = URL(string: business["image_url"].stringValue)
                    
                    let imageRequest = URLRequest(url: imageUrl!)
                    
                    let session = URLSession(configuration: .default)
                    
                    session.dataTask(with: imageRequest, completionHandler: { (data, response, error) in
                        guard let image = data else {
                            print(error?.localizedDescription ?? "error")
                            return
                        }
                        self.imageView.image = UIImage(data: image)
                    }).resume()
                    
                    
                    
                    
                }
            case false:
                print(response.result.error?.localizedDescription ?? "error")
            }
            
        }
    }
    
    /*
     {
     "id" : "the-temporarium-coffee-and-tea-san-francisco",
     "rating" : 5,
     "is_closed" : false,
     "review_count" : 114,
     "phone" : "+14155470616",
     "categories" : [
     {
     "title" : "Coffee & Tea",
     "alias" : "coffee"
     }
     ],
     "image_url" : "https:\/\/s3-media2.fl.yelpcdn.com\/bphoto\/mqP4uGnER6-6g9l9L9QBWA\/o.jpg",
     "url" : "https:\/\/www.yelp.com\/biz\/the-temporarium-coffee-and-tea-san-francisco?adjust_creative=518053Hp9nttpTmK1rW-ig&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=518053Hp9nttpTmK1rW-ig",
     "price" : "$",
     "location" : {
     "city" : "San Francisco",
     "country" : "US",
     "address1" : "3414 22nd St",
     "zip_code" : "94111",
     "address3" : "",
     "state" : "CA",
     "address2" : ""
     },
     "coordinates" : {
     "longitude" : -122.4235786,
     "latitude" : 37.7552528
     },
     "distance" : 1412.2572302276,
     "name" : "The Temporarium Coffee & Tea"
     }
     
     */
    

}

