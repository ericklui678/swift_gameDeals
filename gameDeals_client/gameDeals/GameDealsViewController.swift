//
//  ViewController.swift
//  gameDeals
//
//  Created by Erick Lui on 7/18/17.
//  Copyright © 2017 Erick Lui. All rights reserved.
//

import Foundation
import UIKit

class GameDealsViewController: UITableViewController {
  
  var games = [NSDictionary]()
  var refresher: UIRefreshControl!

  override func viewDidLoad() {
    super.viewDidLoad()
    retrieveAllDeals()
    
    refresher = UIRefreshControl()
    refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
    refresher.addTarget(self, action: #selector(retrieveAllDeals), for: UIControlEvents.valueChanged)
    tableView.addSubview(refresher)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return games.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCell
    cell.selectionStyle = .none
    URLSession.shared.dataTask(with: NSURL(string: games[indexPath.row]["thumb"] as! String)! as URL, completionHandler: { (data, response, error) -> Void in
      if error != nil {
        print(error ?? "error")
        return
      }
      // Load images and titles asynchronously to prevent scroll lag
      DispatchQueue.main.async(execute: { () -> Void in
        cell.thumbnail.image = UIImage(data: data!)
        cell.titleLabel?.text = self.games[indexPath.row]["title"] as? String
        
        cell.salePriceLabel.textColor = UIColor(red: 0, green: 0.4, blue: 0, alpha: 1)
        cell.salePriceLabel?.text = "$\(self.games[indexPath.row]["salePrice"]!)"
        
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.red]
        let currPrice = NSMutableAttributedString(string: "$\(self.games[indexPath.row]["normalPrice"]!)", attributes: attributes)
        currPrice.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, currPrice.length))
        cell.currentPriceLabel?.attributedText = currPrice
        
        if let percent = Double(self.games[indexPath.row]["savings"] as! String) {
          let percentStr = String(Int(percent.rounded()))
          cell.percentLabel?.backgroundColor = UIColor(red: 0, green: 0.4, blue: 0, alpha: 1)
          cell.percentLabel?.text = "\(percentStr)%"
        }
      })
      
    }).resume()
    return cell
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    
  }
  
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let addAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Add") { (action , indexPath ) -> Void in
      self.isEditing = false
      print("Add button pressed")
    }
    addAction.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
    return [addAction]
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let url = URL(string: "http://www.cheapshark.com/redirect?dealID=\(games[indexPath.row]["dealID"]!)")!
    if UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
      //If you want handle the completion block than
      UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
        print("Open url : \(success)")
      })
    }
  }
  
  @objc func retrieveAllDeals() {
    DealsModel.getAllDeals(completionHandler: {
      data, response, error in
      do {
        if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [NSDictionary] {
          self.games = jsonResult
          DispatchQueue.main.async {
            print("API calling now")
            self.tableView.reloadData()
            self.refresher.endRefreshing()
          }
        }
      } catch {
        print(error)
      }
    })
  }
}


