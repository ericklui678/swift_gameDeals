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
    var stores: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(gameID!)
        retrieveStores()
        displayDetails()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
//                    print(self.deals)
                    DispatchQueue.main.async {
                        self.navigationItem.title = (jsonResult["info"] as! NSDictionary)["title"]! as! String
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
                    self.stores = (jsonResult as NSArray)
//                    print(self.stores)
                    DispatchQueue.main.async {
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
            print(storeID)
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
