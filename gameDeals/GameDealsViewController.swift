//
//  ViewController.swift
//  gameDeals
//
//  Created by Erick Lui on 7/18/17.
//  Copyright © 2017 Erick Lui. All rights reserved.
//

import UIKit

class GameDealsViewController: UITableViewController {
  
  var games = [NSDictionary]()

  override func viewDidLoad() {
    super.viewDidLoad()
    retrieveAllDeals()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return games.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCell
    URLSession.shared.dataTask(with: NSURL(string: games[indexPath.row]["thumb"] as! String)! as URL, completionHandler: { (data, response, error) -> Void in
      if error != nil {
        print(error ?? "error")
        return
      }
      // Load images and titles asynchronously to prevent scroll lag
      DispatchQueue.main.async(execute: { () -> Void in
        cell.thumbnail.image = UIImage(data: data!)
        cell.titleLabel?.text = self.games[indexPath.row]["title"] as? String
        
        cell.salePriceLabel.textColor = UIColor(red: 0.5, green: 0.65, blue: 0.5, alpha: 1)
        cell.salePriceLabel?.text = "$\(self.games[indexPath.row]["salePrice"]!)"
        
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.red]
        let currPrice = NSMutableAttributedString(string: "$\(self.games[indexPath.row]["normalPrice"]!)", attributes: attributes)
        currPrice.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, currPrice.length))
        cell.currentPriceLabel?.attributedText = currPrice
        
      })
      
    }).resume()
    return cell
  }
  
  func retrieveAllDeals() {
    DealsModel.getAllDeals(completionHandler: {
      data, response, error in
      do {
        if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [NSDictionary] {
          self.games = jsonResult
          DispatchQueue.main.async {
            self.tableView.reloadData()
          }
        }
      } catch {
        print(error)
      }
    })
  }
}


