//
//  UserCellModel.swift
//  GitHubSearcher
//
//  Created by YN on 4/17/20.
//  Copyright © 2020 YN. All rights reserved.
//

import Foundation
import UIKit
class UserCellModel {

    var userName: String
    var repoNumbers: String?
    var avatarImage: UIImage?

    init(userName: String,
         repoNumbers: String? = nil,
         avatarImage: UIImage? = nil) {
        self.userName = userName
        self.repoNumbers = repoNumbers
        self.avatarImage = avatarImage
    }

}
