//
//  DealsModel.swift
//  gameDeals
//
//  Created by Erick Lui on 7/18/17.
//  Copyright © 2017 Erick Lui. All rights reserved.
//

import Foundation

class DealsModel {
  
  static func getAllDeals(completionHandler: @escaping(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
    let url = URL(string: "http://www.cheapshark.com/api/1.0/deals")
    let session = URLSession.shared
    let task = session.dataTask(with: url!, completionHandler: completionHandler)
    task.resume()
  }
  
  static func getAllStores(completionHandler: @escaping(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
    let url = URL(string: "http://www.cheapshark.com/api/1.0/stores")
    let session = URLSession.shared
    let task = session.dataTask(with: url!, completionHandler: completionHandler)
    task.resume()
  }
  
  static func getGameInfo(gameID: String, completionHandler: @escaping(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
    let url = URL(string: "http://www.cheapshark.com/api/1.0/games?id=\(gameID)")
    let session = URLSession.shared
    let task = session.dataTask(with: url!, completionHandler: completionHandler)
    task.resume()
  }
  
  static func getMyList(completionHandler: @escaping(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
    let url = URL(string: "https://gamedeals.herokuapp.com/")
    let session = URLSession.shared
    let task = session.dataTask(with: url!, completionHandler: completionHandler)
    task.resume()
  }
  
  static func deleteGame(index: String, completionHandler: @escaping(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
    if let urlToReq = URL(string: "https://gamedeals.herokuapp.com/" + index) {
      var request = URLRequest(url: urlToReq)
      request.httpMethod = "POST"
      let session = URLSession.shared
      let task = session.dataTask(with: request as URLRequest, completionHandler: completionHandler)
      task.resume()
    }
  }
  
  static func addGame(game_id: String, imgURL: String, title: String, completionHandler: @escaping(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
    print(game_id, imgURL, title)
    if let urlToReq = URL(string: "https://gamedeals.herokuapp.com/create") {
      var request = URLRequest(url: urlToReq)
      request.httpMethod = "POST"
      let bodyData = "game_id=\(game_id)&imgURL=\(imgURL)&title=\(title)"
      request.httpBody = bodyData.data(using: .utf8)
      let session = URLSession.shared
      let task = session.dataTask(with: request as URLRequest, completionHandler: completionHandler)
      task.resume()
    }
  }
}
