//
//  UserDetailModel.swift
//  GitHubSearcher
//
//  Created by YN on 4/17/20.
//  Copyright © 2020 YN. All rights reserved.
//

import Foundation

struct UserDetailModel: Codable {
    let login: String?
    let email: String?
    let bio: String?
    let location: String?
    let created_at: String?
    let followers: Int?
    let following: Int?
    let public_repos: Int?
}
