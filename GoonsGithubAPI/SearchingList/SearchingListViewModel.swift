//
//  SearchingListViewModel.swift
//  GoonsGithubAPI
//
//  Created by Stephen on 2023/10/14.
//

import Foundation

protocol SearchingListViewModelDelegate: AnyObject {
    func viewModel(_ viewModel: SearchingListViewModel)
}

final class SearchingListViewModel {
    
    /// 先取得資料、後取圖片
    
    weak var delegate: SearchingListViewModelDelegate?
    let fetcher = SourceFetcher()
    private var items = [Items]()
//    private var imageStorage: ImageModel?
    
    func fetchResults(at url: URL, _  completion: @escaping(FetchResult<[Items]>) -> Void) {
        fetcher.fetchResults(at: url) { result in
            if case let .success(data) = result {
                self.items = data
                completion(result)
            }
        }
    }
    
//    func fetchImage(indexPathRow: Int, _ completion: @escaping (FetchResult<Data>) -> Void) {
//        fetcher.fetchImage(at: items[indexPathRow].owner.avatar_url) { imageData in
//            if case .success(_) = imageData {
//                completion(imageData)
//            }
//        }
//    }

    func select(index: Int, for data: [URL]) {
        delegate?.viewModel(self)
    }
}
