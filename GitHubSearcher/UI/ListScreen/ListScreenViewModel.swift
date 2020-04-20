//
//  ListScreenViewModel.swift
//  GitHubSearcher
//
//  Created by YN on 4/16/20.
//  Copyright © 2020 YN. All rights reserved.
//

import Foundation
import UIKit
class ListScreenViewModel {
    var gitHubUsers: [Item] = []
    var userCellModels: [UserCellModel] = []
    weak var delegate: ListScreenViewModelDelegate?
    var fetchUsersTask: URLSessionDataTask?
    var fetchReposTasks: [URLSessionDataTask]?
    var fetchAvatarsTasks: [URLSessionDataTask]?
    var currentPage = 1
    var itemsPerpage = 30
    lazy var cache = NSCache<AnyObject, AnyObject>()
    init() {}
    func clear() {
        gitHubUsers = []
        userCellModels = []
        fetchUsersTask?.cancel()
        fetchReposTasks?.forEach { $0.cancel() }
        fetchAvatarsTasks?.forEach { $0.cancel() }
        fetchReposTasks = []
        fetchAvatarsTasks = []
    }
    func fetchUsers(userName: String, page: Int) {
        let networkService = NetworkService.shared
        fetchUsersTask = networkService.users(userName: userName, page: page) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .failure(let error): print(error.localizedDescription)
            case .success(let userModel):
                for item in userModel.items {
                    self.userCellModels.append(UserCellModel(userName: item.login))
                }
                self.gitHubUsers += (userModel.items)
                self.delegate?.insertRows(page: page)
            }
        }
        fetchUsersTask?.resume()
    }
    func fetchRepoNumber(page: Int) {
        let networkService = NetworkService.shared
        for index in ((page - 1) * 30)..<(page*30)  {
            guard index < gitHubUsers.count else { return }
            let item = gitHubUsers[index]
            let taskOp = networkService.userDetail(urlString: item.url) { [weak self] result  in
                guard let self = self else { return }
                switch result {
                case .failure(_):break
                case .success(let userDetailModel):
                    if let repoNumbers = userDetailModel.public_repos, index < self.userCellModels.count {
                        self.userCellModels[index].repoNumbers = "\(repoNumbers)"
                        self.delegate?.reloadCellAt(row: index)
                    }
                }
            }
            if let task = taskOp {
                task.resume()
                fetchReposTasks?.append(task)
            }
        }
    }
    func fetchAvatars(page: Int) {
        for index in ((page - 1) * 30)..<(page*30) {
            guard index < gitHubUsers.count else { return }
            let item = gitHubUsers[index]
            guard let url = URL(string: item.avatarURL) else { continue }
            if let data = cache.object(forKey: item.avatarURL as AnyObject) as? Data {
                userCellModels[index].avatarImage = UIImage(data: data)
                delegate?.reloadCellAt(row: index)
                continue
            }
            
            let task = URLSession(configuration: .default).dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                guard error == nil, let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode), let data = data, index < self.userCellModels.count else { return }
                self.cache.setObject(data as AnyObject, forKey: url.absoluteString as AnyObject)
                self.userCellModels[index].avatarImage = UIImage(data: data)
                self.delegate?.reloadCellAt(row: index)
            }
            task.resume()
            fetchAvatarsTasks?.append(task)
        }
    }
}

protocol ListScreenViewModelDelegate: class {
    /**
    Insert new rows into the table based on page
    - parameter page: The page of the JSON to be insert
    */
    func insertRows(page: Int)
    /**
    Reload a specific row once its correspoding data was downloaded
    - parameter row: The row to be reload
    */
    func reloadCellAt(row: Int)
}
