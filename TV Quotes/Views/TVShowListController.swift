//
//  QuoteListController.swift
//  TV Quotes
//
//  Created by Omar Abbasi on 2018-07-23.
//  Copyright © 2018 Omar Abbasi. All rights reserved.
//

import UIKit
import SDWebImage

private let reuseIdentifier = "tvShowCell"

class TVShowCell: UICollectionViewCell {

    @IBOutlet var name: UILabel!
    @IBOutlet var details: UILabel!
    @IBOutlet var image: UIImageView!
    @IBOutlet var overlay: UIView!

    override func awakeFromNib() {
        let gradient = CAGradientLayer()

        gradient.frame = overlay.bounds
        gradient.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(1).cgColor]
        gradient.locations = [0.3, 1]

        overlay.layer.insertSublayer(gradient, at: 0)
        self.image.contentMode = .scaleAspectFill
    }

    func setDataFromShow(_ show: TVShow) {
        self.name?.text = show.name
        self.details?.text = "\(show.quotes.count) quotes"
        
        guard let url = URL(string: show.image) else { return }
        self.image.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        
    }
    
}

class TVShowListController: UICollectionViewController, RefreshDelegate, UIViewControllerPreviewingDelegate {

    var viewModel = TVShowViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width - 32, height: 170)
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.size.width, height: 20)
        collectionView!.collectionViewLayout = layout

        self.title = "Loading..."
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: collectionView)
        }
        
        viewModel.delegate = self

    }

    func shouldRefresh() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.title = "TV Shows"
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? TVShowCell {
            let tvShow = viewModel.shows[indexPath.row]
            cell.setDataFromShow(tvShow)
            return cell
        } else {
            return UICollectionViewCell()
        }

    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let quoteListViewModel = viewModel.quoteListViewModelForTVShowAtIndexPath(indexPath)
        let quoteListViewController = QuoteListController(viewModel: quoteListViewModel)
        self.navigationController?.pushViewController(quoteListViewController, animated: true)

    }
    
    // MARK: - Previewing Delegate
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let index = collectionView.indexPathForItem(at: location), let cell = collectionView.cellForItem(at: index) as? TVShowCell else { return nil }
        let listViewModel = viewModel.quoteListViewModelForTVShowAtIndexPath(index)
        let quoteList = QuoteListController(viewModel: listViewModel)
        let peekHeight = self.view.bounds.size.height * 0.75
        quoteList.preferredContentSize = CGSize(width: 0.0, height: peekHeight)
        previewingContext.sourceRect = cell.frame
        
        return quoteList
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }

}
