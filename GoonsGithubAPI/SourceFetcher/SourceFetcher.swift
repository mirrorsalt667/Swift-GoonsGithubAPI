//
//  SourceFetcher.swift
//  GoonsGithubAPI
//
//  Created by Stephen on 2023/10/14.
//

import Foundation

enum FetchResult<Value> {
    case success(Value)
    case failure(Error)
}

class SourceFetcher {
    func fetchResults(at url: URL, completionHandler: @escaping (FetchResult<[Items]>) -> Void) {
        print("取得資料")
        var request = URLRequest(url: url,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                let result = FetchResult<[Items]>.failure(error!)
                completionHandler(result)
                return
            }

            do {
                let decoder = JSONDecoder()
                let decodeResults = try decoder.decode(DataModel.self, from: data)
                let result: FetchResult<[Items]> = .success(decodeResults.items)
                completionHandler(result)
            } catch let fetchError {
                let result = FetchResult<[Items]>.failure(fetchError)
                completionHandler(result)
            }
        }
        task.resume()
    }
    
    func fetchImage(at urlString: String, completionHandler: @escaping (FetchResult<Data>) -> Void) {
        guard let url = URL(string: urlString) else {
            return
        }
        print("取得圖片")
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                let result = FetchResult<Data>.failure(error!)
                completionHandler(result)
                return
            }
            
            let result: FetchResult<Data> = .success(data)
            completionHandler(result)
        }
        task.resume()
    }
}
