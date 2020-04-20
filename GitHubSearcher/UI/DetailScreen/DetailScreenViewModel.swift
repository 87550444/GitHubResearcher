//
//  DetailScreenViewModel.swift
//  GitHubSearcher
//
//  Created by YN on 4/17/20.
//  Copyright © 2020 YN. All rights reserved.
//

import Foundation
import UIKit

class DetailScreenViewModel {
    var userURLString: String?
    var avatarURLString: String?
    var avatarImage: UIImage?
    var userName: String?
    weak var delegate: DetailScreenViewModelDelegate?
    var repos: [RepoItem] = []
    var fetchRepoTask: URLSessionTask?
    var currentPage = 1
    var itemsPerpage = 30
    
    init(userURLString: String?, avatarURLString: String?, avatarImage: UIImage?, userName: String?) {
        self.userURLString = userURLString
        self.avatarURLString = avatarURLString
        self.avatarImage = avatarImage
        self.userName = userName
    }
    init(){}
    func fetchUserDetail() {
        let networkService = NetworkService.shared
        guard  let urlString = userURLString else {
            return
        }
        networkService.userDetail(urlString: urlString) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(_): break
            case .success(let userDetailModel):
                self.delegate?.showUserDetail(with: userDetailModel)
            }
        }?.resume()
    }
    func fetchRepos(userName: String, repoName: String?, page: Int) {
        let networkService = NetworkService.shared
        fetchRepoTask = networkService.repos(userName: userName, repoName: repoName, page: page) { result in
            switch result {
            case .failure(_): break
            case .success(let repoModel):
                self.repos += repoModel.items
                self.delegate?.insertNewRows(page: page)
            }
        }
        fetchRepoTask?.resume()
    }
    func clear() {
        fetchRepoTask?.cancel()
        repos = []
    }
}

protocol DetailScreenViewModelDelegate: class {
    /**
     Display User infomation at the top of the screen
     - parameter with: The model saving user infomation
     */
    func showUserDetail(with model: UserDetailModel)
    /**
    Insert new rows into the table based on page
    - parameter page: The page of the JSON to be insert
    */
    func insertNewRows(page: Int)
}
