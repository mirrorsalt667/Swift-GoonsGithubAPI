//
//  SearchingListTableViewController.swift
//  GoonsGithubAPI
//
//  Created by Stephen on 2023/10/14.
//

import UIKit

final class SearchingListTableViewController: UITableViewController {
    
    var viewModel = SearchingListViewModel()
    let urlHeaderString = "https://api.github.com/search/repositories"
    
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
    }
    
    // MARK: - Methods
    
    func fetchResults(url: URL) {
        print("API網址：\(url)")
        viewModel.fetchResults(at: url) { [weak self] results in
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

// MARK: - Searching

extension SearchingListTableViewController: UISearchBarDelegate {
    
    /// 鍵盤按下搜尋
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        guard let text = searchBar.text,
              var urlComps = URLComponents(string: urlHeaderString)
        else { return }
        urlComps.queryItems = [URLQueryItem(name: "q", value: text)]
        
        guard let url = urlComps.url else { return }
        self.fetchResults(url: url)
    }
    
    /// 被清空時，清空table view
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.state.results = []
        }
    }
}
