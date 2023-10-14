//
//  SearchingListTableViewController.swift
//  GoonsGithubAPI
//
//  Created by Stephen on 2023/10/14.
//

import UIKit

final class SearchingListTableViewController: UITableViewController {
    
    struct State {
        var results: [Items]
    }
    
    var state = State(results: []) {
        didSet {
            if oldValue.results != state.results {
                // reload
                self.tableView.reloadData()
            }
        }
    }
    
    let fetcher = SourceFetcher()

    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Repositories"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        fetcher.fetchingData { results in
            DispatchQueue.main.async {
                self.state.results = results
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
        if let url = URL(string: state.results[row].owner.avatar_url),
           let data = try? Data(contentsOf: url),
           let image = UIImage(data: data)
        {
            cell.iconImageView.image = image
        } else {
            cell.iconImageView.image = UIImage(systemName: "questionmark.app")
        }
        
        cell.titleLabel.text = state.results[row].full_name
        cell.descriptionLabel.text = state.results[row].description ?? ""

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
