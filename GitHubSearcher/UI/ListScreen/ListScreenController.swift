//
//  ListScreenController.swift
//  GitHubSearcher
//
//  Created by YN on 4/16/20.
//  Copyright © 2020 YN. All rights reserved.
//

import UIKit

class ListScreenController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    lazy var viewModel = ListScreenViewModel()
    var repoTasks: [URLSessionDataTask] = []
    var timer: Timer?
    var trimmedUserName: String = ""
    lazy var placeHolderImage = UIImage(named: StringConstants.placeHolder.rawValue)
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = StringConstants.navigationTitle.rawValue
        setupTableView()
        viewModel.delegate = self
        searchBar.delegate = self
    }
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        guard let nibName = String(describing: type(of: UserCell.self)).components(separatedBy: ".").first else { return }
        let nib = UINib(nibName: nibName, bundle: Bundle(for: type(of: self)))
        tableView.register(nib, forCellReuseIdentifier: StringConstants.userCell.rawValue)
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
    }
}

extension ListScreenController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: StringConstants.main.rawValue, bundle: nil)
        let detailScreenControllerOptional = storyBoard.instantiateViewController(withIdentifier: StringConstants.detailScreenController.rawValue) as? DetailScreenController
        if let detailScreenController = detailScreenControllerOptional {
            detailScreenController.viewModel = DetailScreenViewModel(userURLString: viewModel.gitHubUsers[indexPath.row].url,
                                                                     avatarURLString: viewModel.gitHubUsers[indexPath.row].avatarURL,
                                                                     avatarImage: viewModel.userCellModels[indexPath.row].avatarImage,
                                                                     userName: viewModel.userCellModels[indexPath.row].userName)
            navigationController?.pushViewController(detailScreenController, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (viewModel.currentPage * viewModel.itemsPerpage - 1) {
            viewModel.currentPage += 1
            viewModel.fetchUsers(userName: trimmedUserName, page: viewModel.currentPage)
        }
    }
}
extension ListScreenController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.userCellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StringConstants.userCell.rawValue) as? UserCell else { return UITableViewCell() }
        let userCellModels = viewModel.userCellModels
        guard indexPath.row < userCellModels.count  else {
            return UITableViewCell()
        }
        let userCellModel = userCellModels[indexPath.row]
        cell.userNameLabel.text = userCellModel.userName
        cell.repoNumberLabel.text = (userCellModel.repoNumbers == nil) ? StringConstants.repoNumberPlaceHolder.rawValue : "\(StringConstants.repo.rawValue)\(userCellModel.repoNumbers!)"
        cell.avatarImageView.image = (userCellModel.avatarImage == nil) ? placeHolderImage : userCellModel.avatarImage!
        cell.selectionStyle = .none
        return cell
    }
}

extension ListScreenController: ListScreenViewModelDelegate {
    func insertRows(page: Int) {
        DispatchQueue.main.async {
            let startRow = (page - 1) * self.viewModel.itemsPerpage
            var indexPaths = [IndexPath]()
            let endRow = min(startRow + self.viewModel.itemsPerpage, self.viewModel.userCellModels.count)
            for row in startRow..<endRow {
                indexPaths.append(IndexPath(row: row, section: 0))
            }
            self.tableView.performBatchUpdates({
                self.tableView.insertRows(at: indexPaths, with: .none)
            }, completion: nil)
            self.viewModel.fetchRepoNumber(page: page)
            self.viewModel.fetchAvatars(page: page)
        }
    }
    func reloadCellAt(row: Int) {
        DispatchQueue.main.async {
            guard self.tableView.numberOfRows(inSection: 0) > row else { return }
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
            self.tableView.endUpdates()
        }
    }
}

extension ListScreenController: UISearchBarDelegate  {
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
                self.trimmedUserName = trimed
                self.viewModel.fetchUsers(userName: trimed, page: self.viewModel.currentPage)
            }
        })
    }
}
