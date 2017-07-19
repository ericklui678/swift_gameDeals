//
//  WatchListTableViewController.swift
//  gameDeals
//
//  Created by Erick Lui on 7/19/17.
//  Copyright © 2017 Erick Lui. All rights reserved.
//

import UIKit

class WatchListTableViewController: UITableViewController {
  
  var list = [NSDictionary]()

  override func viewDidLoad() {
    super.viewDidLoad()
    retrieveMyList()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    retrieveMyList()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return list.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "WatchlistCell") as! WatchlistCell
//    cell.titleLabel.text = list[indexPath.row]["title"] as? String
    URLSession.shared.dataTask(with: NSURL(string: list[indexPath.row]["imgURL"] as! String)! as URL, completionHandler: { (data, response, error) -> Void in
      if error != nil {
        print(error ?? "error")
        return
      }
      // Load images and titles asynchronously to prevent scroll lag
      DispatchQueue.main.async(execute: { () -> Void in
        cell.thumbnail.image = UIImage(data: data!)
        cell.titleLabel?.text = self.list[indexPath.row]["title"] as? String
      })
      
    }).resume()
    cell.accessoryType = .detailButton
    return cell
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    deleteGame(list[indexPath.row]["game_id"] as! String)
    list.remove(at: indexPath.row)
    tableView.reloadData()
  }
  
  override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    print("accessory tapped")
  }
  
  func retrieveMyList() {
    DealsModel.getMyList(completionHandler: {
      data, response, error in
      do {
        if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [NSDictionary] {
          self.list = jsonResult
          DispatchQueue.main.async {
            self.tableView.reloadData()
          }
        }
      } catch {
        print(error)
      }
    })
  }
  func deleteGame(_ index: String) {
    DealsModel.deleteGame(index: index, completionHandler: {
      data, response, error in
      do {
        if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [NSDictionary] {
          self.list = jsonResult
        }
      } catch {
        print(error)
      }
    })
  }
}
