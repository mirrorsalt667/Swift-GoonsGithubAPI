//
//  SearchingListTableViewController.swift
//  GoonsGithubAPI
//
//  Created by Stephen on 2023/10/14.
//

import UIKit

final class SearchingListTableViewController: UITableViewController {
    
    var viewModel = SearchingListViewModel()
    
    struct State {
        var results: [Items]
        var imageModel: [ImageModel]
//        var newLoadImage: ImageModel
    }
    
    var state = State(results: [], imageModel: []) {
        didSet {
            if oldValue.results != state.results {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            if oldValue.imageModel != state.imageModel {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
//            if oldValue.newLoadImage != state.newLoadImage {
//                DispatchQueue.main.async {
//                    let row = self.state.newLoadImage.id
//                    print("刷新row: \(row)")
//                    self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
//                }
//            }
        }
    }

    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Repositories"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        viewModel.fetchResults(at: URL(string: "https://api.github.com/search/repositories?q=pink%20apple")!) { [weak self] results in
            switch results {
            case .success(let items):
                self?.state.results = items
                // 創造一樣多的空位image array
                self?.state.imageModel = Array(repeating: ImageModel(id: 0, imageData: Data()), count: items.count)
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.results.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchingListTableViewCell", for: indexPath) as! SearchingListTableViewCell
        let row = indexPath.row
        let imageData = state.imageModel[row].imageData
        if imageData != Data() {
            cell.iconImageView.image = UIImage(data: imageData)
        } else {
            cell.iconImageView.image = UIImage(systemName: "questionmark.app")
            // 獲取圖片
            viewModel.fetchImage(indexPathRow: row) { result in
                switch result {
                case .success(let imageData):
                    self.state.imageModel[row] = ImageModel(id: row, imageData: imageData)
                case .failure(let error):
                    print("錯誤: \(error)")
                }
            }
        }
        cell.titleLabel.text = state.results[row].full_name
        cell.descriptionLabel.text = state.results[row].description ?? ""

        return cell
    }
}
