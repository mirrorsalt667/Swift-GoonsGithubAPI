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
    let customRefreshControl = UIRefreshControl()
    
    struct State {
        var results: [Items]
        var imageModel: [ImageModel]
        var searchingUrl: URL?
//        var newLoadImage: ImageModel
    }
    
    var state = State(results: [], imageModel: [], searchingUrl: nil) {
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
            if oldValue.searchingUrl != state.searchingUrl {
                if let url = state.searchingUrl {
                    self.fetchResults(url: url)
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
    
    @IBOutlet weak var topView: UIView!

    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Repositories"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.addSubview(customRefreshControl)
        customRefreshControl.addTarget(self, action: #selector(refreshResults), for: .valueChanged)
    }
    
    // MARK: - Methods
    
    /// 取得資料
    func fetchResults(url: URL) {
        print("API網址-f：\(url)")
        viewModel.fetchResults(at: url) { [weak self] results in
            switch results {
            case .success(let items):
                self?.state.results = items
                // 創造一樣多的空位image array
                self?.state.imageModel = Array(repeating: ImageModel(id: 0, imageData: Data()), count: items.count)
                // 結束更新動畫
                self?.endRefresh()
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    /// 下拉更新
    @objc func refreshResults() {
        guard let url = state.searchingUrl else {
            self.showAlert(title: "Oops!", msg: "The data couldn’t be read because it is missing.") { alert in
                self.endRefresh()
            }
            return
        }
        print("下拉更新")
        fetchResults(url: url)
    }
    
    /// 結束下拉更新動畫
    func endRefresh() {
        DispatchQueue.main.async {
            self.customRefreshControl.endRefreshing()
        }
    }
    
    /// 顯示警告提示框
    func showAlert(title: String, msg: String, handler: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: handler)
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
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
    
    /// 選擇的Row，轉換頁面，傳資料
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Detailed", bundle: nil)
        if let detailedViewController = storyboard.instantiateViewController(identifier: "DetailedViewController") as? DetailedViewController {
            detailedViewController.detailedState = DetailedViewController.DetailState(
                results: self.state.results[indexPath.row],
                imageModel: self.state.imageModel[indexPath.row]
            )
            navigationController?.navigationBar.backgroundColor = .clear
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
            navigationController?.pushViewController(detailedViewController, animated: true)
        }
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
        // 是空白嗎
        if !text.isEmpty {
            urlComps.queryItems = [URLQueryItem(name: "q", value: text)]
            
            guard let url = urlComps.url else { return }
            self.state.searchingUrl = url
        }
    }
    
    /// 被清空時，清空table view
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.state.results = []
            self.state.imageModel = []
            self.state.searchingUrl = nil
        }
    }
}


// MARK: Scroll View

extension SearchingListTableViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        if let navi = navigationController?.navigationBar {
            if yOffset >= -20 {
                navi.backgroundColor = .black
                navi.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
            } else {
                navi.backgroundColor = .clear
                navi.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
            }
        }
    }
}
