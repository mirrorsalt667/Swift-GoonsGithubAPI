//
//  CustomNavigationController.swift
//  GoonsGithubAPI
//
//  Created by Stephen on 2023/10/15.
//

import UIKit

final class CustomNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.prefersLargeTitles = true
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationItem.largeTitleDisplayMode = .never
    }
}
