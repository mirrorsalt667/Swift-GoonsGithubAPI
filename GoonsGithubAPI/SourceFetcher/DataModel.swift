//
//  DataModel.swift
//  GoonsGithubAPI
//
//  Created by Stephen on 2023/10/14.
//

import Foundation

struct DataModel: Decodable, Equatable {
    let items: [Items]
}

struct Items: Decodable, Equatable {
    let id: Int
    let name: String
    let full_name: String
    let description: String?
    let language: String?
    let stargazers_count: Int
    let watchers_count: Int
    let forks_count: Int
    let open_issues_count: Int
    let owner: Owner
}

struct Owner: Decodable, Equatable {
    let avatar_url: String
}

struct ImageModel: Equatable {
    let id: Int
    let imageData: Data
}
