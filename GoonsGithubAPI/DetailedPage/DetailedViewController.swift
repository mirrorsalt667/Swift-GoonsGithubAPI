//
//  DetailedViewController.swift
//  GoonsGithubAPI
//
//  Created by Stephen on 2023/10/14.
//

import UIKit

final class DetailedViewController: UIViewController {

    struct DetailState {
        var results: Items
        var imageModel: ImageModel
    }
    
    var detailedState: DetailState?
    
    // MARK: Components
    
    @IBOutlet weak var nameTitleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var starCountLabel: UILabel!
    @IBOutlet weak var watcherCountLabel: UILabel!
    @IBOutlet weak var forkCountLabel: UILabel!
    @IBOutlet weak var issueCountLabel: UILabel!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let detailedState = detailedState else { return }
        DispatchQueue.main.async {
            self.setData(detail: detailedState)
        }
    }
    
    // MARK: Methods
    
    func setData(detail: DetailState) {
        nameTitleLabel.text = detail.results.name
        if let image = UIImage(data: detail.imageModel.imageData) {
            iconImageView.image = image
        }
        fullNameLabel.text = detail.results.full_name
        languageLabel.text = "written by \(detail.results.language ?? "unknow")"
        starCountLabel.text = "star counter: \(detail.results.stargazers_count)"
        watcherCountLabel.text = "watcher counter: \(detail.results.watchers_count)"
        forkCountLabel.text = "fork counter: \(detail.results.forks_count)"
        issueCountLabel.text = "open issue counter: \(detail.results.open_issues_count)"
    }
}
