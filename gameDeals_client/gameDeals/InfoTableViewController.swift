//
//  InfoTableViewController.swift
//  gameDeals
//
//  Created by Erick Lui on 7/19/17.
//  Copyright © 2017 Erick Lui. All rights reserved.
//

import UIKit

class InfoTableViewController: UITableViewController {
  
  var stores = [NSDictionary]()
  var deals = NSArray()
  var game_id: String?

  override func viewDidLoad() {
    super.viewDidLoad()
    DispatchQueue.main.async {
      self.retrieveAllStores()
      self.retrieveGameInfo()
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return deals.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCustomCell") as! InfoCustomCell
    cell.selectionStyle = .none
    // Load images and titles asynchronously to prevent scroll lag
    DispatchQueue.main.async(execute: { () -> Void in
      cell.priceLabel.text = "$\((self.deals[indexPath.row] as! NSDictionary)["price"]! as! String)"
      cell.retailPriceLabel.text = "$\((self.deals[indexPath.row] as! NSDictionary)["retailPrice"]! as! String)"
      
      let storeID = Int(((self.deals[indexPath.row] as! NSDictionary)["storeID"] as! String))!
      cell.titleLabel.text = self.stores[storeID-1]["storeName"]! as? String
      
      let url = URL(string: "http://www.cheapshark.com/img/stores/banners/\(storeID-1).png")
      let data = try? Data(contentsOf: url!)
      
      if let imageData = data {
        let image = UIImage(data: imageData)
        cell.thumbnail.image = image
      }
    })
    return cell
  }
  
  func retrieveGameInfo() {
    DealsModel.getGameInfo(gameID: self.game_id!, completionHandler: {
      data, response, error in
      do {
        if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
          self.deals = jsonResult["deals"] as! NSArray
          self.tableView.reloadData()
          DispatchQueue.main.async {
            self.navigationItem.title = (jsonResult["info"] as! NSDictionary)["title"]! as? String
          }
        }
      } catch {
        print(error)
      }
    })
  }
  
  func retrieveAllStores() {
    DealsModel.getAllStores(completionHandler: {
      data, response, error in
      do {
        if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [NSDictionary] {
          self.stores = jsonResult
          DispatchQueue.main.async {
//            print(self.stores)
//            self.tableView.reloadData()
          }
        }
      } catch {
        print(error)
      }
    })
  }
  
}
