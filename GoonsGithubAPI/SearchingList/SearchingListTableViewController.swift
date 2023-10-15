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
    }
    
    var state = State(results: []) {
        didSet {
            if oldValue.results != state.results {
                // reload
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
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
            case .success(let items): self?.state.results = items
            case .failure(let error): print("error: \(error.localizedDescription)")
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
        cell.iconImageView.image = UIImage(systemName: "questionmark.app")
        cell.titleLabel.text = state.results[row].full_name
        cell.descriptionLabel.text = state.results[row].description ?? ""

        return cell
    }
}
