//
//  RepoModel.swift
//  GitHubSearcher
//
//  Created by YN on 4/17/20.
//  Copyright © 2020 YN. All rights reserved.
//

import Foundation

struct RepoItem: Codable {
    let name: String?
    let forks_count: Int?
    let stargazers_count: Int?
    let html_url: String?
}
struct RepoModel: Codable {
    let items: [RepoItem]
}
