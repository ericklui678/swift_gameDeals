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
    let url = URL(string: games[indexPath.row]["thumb"] as! String)
    let data = try? Data(contentsOf: url!)
    cell.thumbnail.image = UIImage(data: data!)
    cell.titleLabel?.text = games[indexPath.row]["title"] as? String
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

