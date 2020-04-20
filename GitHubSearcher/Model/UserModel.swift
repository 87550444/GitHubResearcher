//
//  UserModel.swift
//  GitHubSearcher
//
//  Created by YN on 4/17/20.
//  Copyright © 2020 YN. All rights reserved.
//

import Foundation


struct UserModel: Codable {
    let items: [Item]
}


struct Item: Codable {
    let login: String
    let avatarURL: String
    let url: String
    let reposURL:String
    enum CodingKeys: String, CodingKey {
        case login
        case avatarURL = "avatar_url"
        case url
        case reposURL = "repos_url"
    }
}
