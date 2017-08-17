//
//  ViewController.swift
//  gameDeals
//
//  Created by Erick Lui on 7/18/17.
//  Copyright © 2017 Erick Lui. All rights reserved.
//

import Foundation
import UIKit

class GameDealsViewController: UITableViewController, UISearchBarDelegate {
  
  var games = [NSDictionary]()
  var refresher: UIRefreshControl!
  
  @IBOutlet weak var searchBar: UISearchBar!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchBar.delegate = self
    
    retrieveAllDeals()
    
    refresher = UIRefreshControl()
    refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
    refresher.addTarget(self, action: #selector(retrieveAllDeals), for: UIControlEvents.valueChanged)
    tableView.addSubview(refresher)
  }
  
  override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    searchBar.endEditing(true)
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.endEditing(true)
    var foundGames = [NSDictionary]()
    for game in games {
      let title = (game["title"]! as! String).lowercased()
      let searchText = searchBar.text!.lowercased()
      if title.contains(searchText) {
        foundGames.append(game)
      }
    }
    self.games = foundGames
    tableView.reloadData()
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
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
    
//    print(games[indexPath.row]["thumb"])
    
    var url = NSURL(string: "")! as URL
    
    if NSURL(string: games[indexPath.row]["thumb"] as! String) == nil {
      url = NSURL(string: "https://image.flaticon.com/icons/png/512/78/78299.png")! as URL
    } else {
      url = NSURL(string: games[indexPath.row]["thumb"] as! String)! as URL
    }
    
    URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
      
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
  
  
  func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
    URLSession.shared.dataTask(with: url) {
      (data, response, error) in
      completion(data, response, error)
      }.resume()
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    
  }
  
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let addAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Add") { (action , indexPath ) -> Void in
      self.isEditing = false
      let game_id = self.games[indexPath.row]["gameID"]! as! String
      let imgURL = self.games[indexPath.row]["thumb"]! as! String
      let title = self.games[indexPath.row]["title"]! as! String
      self.addGame(game_id, imgURL, title)
      
      let alert = UIAlertController(title: "Success", message: "Game was added to your list", preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
      self.present(alert, animated: true, completion: nil)
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
  
  func addGame(_ game_id: String, _ imgURL: String, _ title: String) {
    DealsModel.addGame(game_id: game_id, imgURL: imgURL, title: title, completionHandler: {
      data, response, error in
      do {
        if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [NSDictionary] {
//          print(jsonResult)
        }
      } catch {
        print(error)
      }
    })
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

//extension UIImageView {
//  func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
//    contentMode = mode
//    URLSession.shared.dataTask(with: url) { (data, response, error) in
//      guard
//        let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
//        let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
//        let data = data, error == nil,
//        let image = UIImage(data: data)
//        else { return }
//      DispatchQueue.main.async() { () -> Void in
//        self.image = image
//      }
//      }.resume()
//  }
//  func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
//    guard let url = URL(string: link) else { return }
//    downloadedFrom(url: url, contentMode: mode)
//  }
//}


