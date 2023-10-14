//
//  SourceFetcher.swift
//  GoonsGithubAPI
//
//  Created by Stephen on 2023/10/14.
//

import Foundation

class SourceFetcher {
    func fetchingData(callback: @escaping ([Items]) -> Void) {
        print("取得資料")
        var request = URLRequest(url: URL(string: "https://api.github.com/search/repositories?q=pink%20apple")!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            do {
                let decoder = JSONDecoder()
                let receive = try decoder.decode(DataModel.self, from: data)
                callback(receive.items)
            } catch let (e) {
                print("API Error: \(e)")
            }
        }
        
        task.resume()
    }
}
