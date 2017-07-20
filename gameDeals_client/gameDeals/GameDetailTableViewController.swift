//
//  GameDetailTableViewController.swift
//  gameDeals
//
//  Created by Kaan Kabalak on 7/19/17.
//  Copyright © 2017 Erick Lui. All rights reserved.
//

import UIKit

class GameDetailTableViewController: UITableViewController {
    
    var gameID: String?
    var deals: NSArray = []
    var stores = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("id is", gameID!)
        retrieveStores()
        displayDetails()
        print(self.stores)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return deals.count
    }
    
    func retrieveStores() {
        // specify the url that we will be sending the GET request to
        let url = URL(string: "http://www.cheapshark.com/api/1.0/stores")
        // create a URLSession to handle the request tasks
        let session = URLSession.shared
        // create a "data task" to make the request and run completion handler
        let task = session.dataTask(with: url!, completionHandler: {
            // see: Swift closure expression syntax
            data, response, error in
            // data -> JSON data, response -> headers and other meta-information, error-> if one occurred
            // "do-try-catch" blocks execute a try statement and then use the catch statement for errors
            do {
                // Try converting the JSON object to "Foundation Types" (NSDictionary, NSArray, NSString, etc.)
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [NSDictionary] {
                    print("record store")
                    self.stores = jsonResult
                }
            } catch {
                print("Something went wrong")
            }
        })
        // execute the task and then wait for the response
        // to run the completion handler. This is async!
        task.resume()
    }
    
    
    func displayDetails() {
        // specify the url that we will be sending the GET request to
        let url = URL(string: "http://www.cheapshark.com/api/1.0/games?id=\(gameID!)")
        // create a URLSession to handle the request tasks
        let session = URLSession.shared
        // create a "data task" to make the request and run completion handler
        let task = session.dataTask(with: url!, completionHandler: {
            // see: Swift closure expression syntax
            data, response, error in
            // data -> JSON data, response -> headers and other meta-information, error-> if one occurred
            // "do-try-catch" blocks execute a try statement and then use the catch statement for errors
            do {
                // Try converting the JSON object to "Foundation Types" (NSDictionary, NSArray, NSString, etc.)
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                    self.deals = (jsonResult["deals"] as! NSArray)
                    DispatchQueue.main.async {
                        self.navigationItem.title = (jsonResult["info"] as! NSDictionary)["title"]! as! String
                        print("API calling now")
                        self.tableView.reloadData()
                    }
                }
            } catch {
                print("Something went wrong")
            }
        })
        // execute the task and then wait for the response
        // to run the completion handler. This is async!
        task.resume()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsCell", for: indexPath) as! DetailsCell

        // Configure the cell...
        DispatchQueue.main.async(execute: { () -> Void in
            cell.salePriceLabel.text = "$\((self.deals[indexPath.row] as! NSDictionary)["price"]! as! String)"
            cell.currentPriceLabel.text = "$\((self.deals[indexPath.row] as! NSDictionary)["retailPrice"]! as! String)"
            
            let storeID = Int(Double((self.deals[indexPath.row] as! NSDictionary)["storeID"]! as! String)!)
//            cell.titleLabel.text = ((self.deals[indexPath.row] as! NSDictionary)["storeID"]! as! String)
            cell.titleLabel.text = (self.stores[storeID-1] as! NSDictionary)["storeName"]! as! String
            
            
            // Swift 3
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "$\((self.deals[indexPath.row] as! NSDictionary)["retailPrice"]!)")
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
            cell.currentPriceLabel?.attributedText = attributeString

            
            
            
            cell.salePriceLabel.textColor = UIColor(red: 0, green: 0.4, blue: 0, alpha: 1)
            
            cell.currentPriceLabel?.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
            
            
            // images
            let url = URL(string: "http://www.cheapshark.com/img/stores/banners/\(storeID-1).png")
            let data = try? Data(contentsOf: url!)
            
            if let imageData = data {
                let image = UIImage(data: imageData)
                cell.thumbnail.image = image
            }
        
        })

        
        //        print((self.deals[indexPath.row] as! NSDictionary)["price"]!)
        return cell
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
