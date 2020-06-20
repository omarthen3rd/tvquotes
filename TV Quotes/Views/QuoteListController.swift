//
//  QuoteListController.swift
//  TV Quotes
//
//  Created by Omar Abbasi on 2018-07-24.
//  Copyright © 2018 Omar Abbasi. All rights reserved.
//

//swiftlint:disable trailing_whitespace line_length

import UIKit

class QuoteTableCell: UITableViewCell {

    @IBOutlet var bgView: UIView!
    @IBOutlet var quoteLabel: UILabel!
    @IBOutlet var detailsLabel: UILabel!

}

class QuoteListController: UITableViewController, UIViewControllerPreviewingDelegate {
    
    private let viewModel: QuoteListViewModel
    private var searchViewModel: SearchViewModelType!

    init(viewModel: QuoteListViewModel) {
        self.viewModel = viewModel
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        self.title = viewModel.show.name

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search \(viewModel.show.name) Quotes"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        }
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: tableView)
        }
        definesPresentationContext = true
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 91
        self.tableView.register(UINib(nibName: "QuoteTableCell", bundle: nil), forCellReuseIdentifier: "quoteCell")

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

    }
    
    @available(iOS 13.0, *)
    func makeContextMenu(indexPath: IndexPath) -> UIMenu {

        // Create a UIAction for copying
        let copy = UIAction(title: "Copy Quote", image: UIImage(systemName: "doc.on.doc")) { action in
            let pasteboard = UIPasteboard.general
            let model = self.viewModel.quoteViewModelForQuoteAtIndexPath(indexPath)
            pasteboard.string = model.quote.quote
        }

        // Create and return a UIMenu with the copy action
        return UIMenu(title: "", children: [copy])
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "quoteCell", for: indexPath) as? QuoteTableCell {

            let quote = viewModel.getQuotes()[indexPath.row]
            cell.selectionStyle = .default
            cell.quoteLabel?.text = quote.quote
            cell.detailsLabel?.text = quote.quoter

            return cell

        } else {
            return UITableViewCell()
        }

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        
        let quoteViewModel = viewModel.quoteViewModelForQuoteAtIndexPath(indexPath)
        let quoteViewController = QuoteViewController(viewModel: quoteViewModel)
        self.navigationController?.present(quoteViewController, animated: true, completion: nil)

    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 91
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @available(iOS 13.0, *)
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: { () -> UIViewController? in
            
            let quoteViewModel = self.viewModel.quoteViewModelForQuoteAtIndexPath(indexPath)
            let quoteVC = QuoteViewController(viewModel: quoteViewModel)
            
            return quoteVC
            
        }, actionProvider: { suggestedActions in
            
            return self.makeContextMenu(indexPath: indexPath)
            
        })
        
    }
    
    // MARK: - Previewing delegate
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let index = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: index) else { return nil }
        let quoteViewModel = viewModel.quoteViewModelForQuoteAtIndexPath(index)
        let quoteVC = QuoteViewController(viewModel: quoteViewModel)
        let peekHeight = self.view.bounds.size.height * 0.75
        quoteVC.preferredContentSize = CGSize(width: 0.0, height: peekHeight)
        previewingContext.sourceRect = cell.frame
        
        return quoteVC
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let newVC = viewControllerToCommit as? QuoteViewController else { return }
        newVC.quoteTextView.centerVertically()
        if #available(iOS 11.0, *) {
            newVC.navigationController?.navigationBar.prefersLargeTitles = false
        }
        show(newVC, sender: self)
    }

}

extension QuoteListController: UISearchResultsUpdating, SearchRepositoriesDelegate {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.query = searchController.searchBar.text!
    }

    func searchResultsDidChanged() {
        self.tableView.reloadData()
    }
}
