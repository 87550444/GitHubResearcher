//
//  DetailScreenController.swift
//  GitHubSearcher
//
//  Created by YN on 4/17/20.
//  Copyright © 2020 YN. All rights reserved.
//

import UIKit

class DetailScreenController: UIViewController {
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var joinDateLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    lazy var viewModel: DetailScreenViewModel = DetailScreenViewModel()
    var timer: Timer?
    
    var trimmedRepoName: String? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = StringConstants.navigationTitle.rawValue
        viewModel.delegate = self
        viewModel.fetchUserDetail()
        setupTableView()
        searchBar.delegate = self
        viewModel.fetchRepos(userName: viewModel.userName ?? "", repoName: nil, page: 1)
    }
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        guard let nibName = String(describing: type(of: RepoCell.self)).components(separatedBy: ".").first else { return }
        let nib = UINib(nibName: nibName, bundle: Bundle(for: type(of: self)))
        tableView.register(nib, forCellReuseIdentifier: StringConstants.repoCell.rawValue)
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
    }
}

extension DetailScreenController: DetailScreenViewModelDelegate {
    func showUserDetail(with model: UserDetailModel) {
        DispatchQueue.main.async {
            self.userNameLabel.text = "\(StringConstants.userName.rawValue)\(model.login ?? "")"
            self.emailLabel.text = "\(StringConstants.email.rawValue)\(model.email ?? "")"
            self.locationLabel.text = "\(StringConstants.location.rawValue)\(model.location ?? "")"
            self.joinDateLabel.text = "\(StringConstants.joinDate.rawValue)\(model.created_at ?? "")"
            self.followersLabel.text = "\(model.followers ?? 0)\(StringConstants.followers.rawValue)"
            self.followingLabel.text = "\(StringConstants.following.rawValue)\(model.following ?? 0)"
            if let avatar = self.viewModel.avatarImage {
                self.avatarImageView.image = avatar
            } else {
                DispatchQueue.global().async {
                    if let urlString = self.viewModel.avatarURLString, let url = URL(string: urlString), let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            self.avatarImageView.image = UIImage(data: data)
                        }
                    }
                }
            }
            self.bioLabel.text = model.bio
        }
    }
    func insertNewRows(page: Int) {
        DispatchQueue.main.async {
            let startRow = (page - 1) * self.viewModel.itemsPerpage
            var indexPaths = [IndexPath]()
            let endRow = min(startRow + self.viewModel.itemsPerpage, self.viewModel.repos.count)
            for row in startRow..<endRow {
                indexPaths.append(IndexPath(row: row, section: 0))
            }
            self.tableView.performBatchUpdates({
                self.tableView.insertRows(at: indexPaths, with: .none)
            }, completion: nil)
        }
    }
}

extension DetailScreenController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (viewModel.currentPage * viewModel.itemsPerpage - 1) {
            viewModel.currentPage += 1
            viewModel.fetchRepos(userName: viewModel.userName ?? "", repoName: trimmedRepoName, page: viewModel.currentPage)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let urlString = viewModel.repos[indexPath.row].html_url else {
            return
        }
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

extension DetailScreenController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.repos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellOptional = tableView.dequeueReusableCell(withIdentifier: StringConstants.repoCell.rawValue) as? RepoCell
        guard let cell = cellOptional else {
            return UITableViewCell()
        }
        let repoItems = viewModel.repos
        cell.repoNameLabel.text = repoItems[indexPath.row].name
        cell.forksLabel.text = "\(repoItems[indexPath.row].forks_count ?? 0)\(StringConstants.forks.rawValue)"
        cell.starsLabel.text = "\(repoItems[indexPath.row].stargazers_count ?? 0)\(StringConstants.stars.rawValue)"
        cell.selectionStyle = .none
        return cell
    }
}

extension DetailScreenController: UISearchBarDelegate  {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        /**Use a timer to prevent frequent reloading*/
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { [weak self] (_) in
            guard let self = self else { return }
            self.viewModel.currentPage = 1
            self.viewModel.clear()
            self.tableView.reloadData()
            if searchText.count > 0 {
                let trimed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                self.trimmedRepoName = trimed
                self.viewModel.fetchRepos(userName: self.viewModel.userName ?? "", repoName: trimed, page: self.viewModel.currentPage)
            } else {
                self.viewModel.fetchRepos(userName: self.viewModel.userName ?? "", repoName: nil, page: 1)
            }
        })
    }
}
