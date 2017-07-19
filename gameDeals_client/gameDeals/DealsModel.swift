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
  
  static func getMyList(completionHandler: @escaping(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
    let url = URL(string: "http://localhost:8000")
    let session = URLSession.shared
    let task = session.dataTask(with: url!, completionHandler: completionHandler)
    task.resume()
  }
  
  static func deleteGame(index: String, completionHandler: @escaping(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
    if let urlToReq = URL(string: "http://localhost:8000/delete/" + index) {
      var request = URLRequest(url: urlToReq)
      request.httpMethod = "POST"
      let session = URLSession.shared
      let task = session.dataTask(with: request as URLRequest, completionHandler: completionHandler)
      task.resume()
    }
  }
}