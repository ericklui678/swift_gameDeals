//
//  ViewController.swift
//  gameDeals
//
//  Created by Erick Lui on 7/18/17.
//  Copyright © 2017 Erick Lui. All rights reserved.
//

import UIKit

class GameDealsViewController: UITableViewController, UISearchBarDelegate {
  
  let searchBar = UISearchBar()
  var games = [NSDictionary]()

  override func viewDidLoad() {
    super.viewDidLoad()
    createSearchBar()
    retrieveAllDeals()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  func createSearchBar(){
    
    searchBar.showsCancelButton = false
    searchBar.placeholder = "Enter your search here!"
    searchBar.delegate = self
    searchBar.showsScopeBar = true
    
    self.navigationItem.titleView = searchBar
  }
    
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            retrieveAllDeals()
        }
        else {
         
            DealsModel.searchGame(nameString: searchBar.text!, completionHandler: {
                data, response, error in
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [NSDictionary] {
                        print(jsonResult)
                        
                        
                        
                        self.games = jsonResult
//                        print(self.games)
//                        DispatchQueue.main.async {
//                            self.tableView.reloadData()
//                        }
                    }
                } catch {
                    print(error)
                }
            })
        }
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
        cell.currentPriceLabel?.text = self.games[indexPath.row]["normalPrice"] as? String
        
      })
      
    }).resume()
    return cell
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
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}


