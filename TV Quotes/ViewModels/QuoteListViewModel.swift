//
//  QuoteListViewModel.swift
//  TV Quotes
//
//  Created by Omar Abbasi on 2018-07-24.
//  Copyright © 2018 Omar Abbasi. All rights reserved.
//

import UIKit

protocol SearchRepositoriesDelegate: class {
    func searchResultsDidChanged()
}

protocol SearchViewModelType {

    var filteredQuotes: [Quote] {get}
    var query: String {get set}
    var delegate: SearchRepositoriesDelegate? {get set}

}

public final class QuoteListViewModel: SearchViewModelType {

    public var query: String = "" {
        didSet {
            query == "" ? filteredQuotes = [] : performSearch()
        }
    }

    public var filteredQuotes: [Quote] = [] {
        didSet {
            delegate?.searchResultsDidChanged()
        }
    }

    weak var delegate: SearchRepositoriesDelegate?

    // MARK: - Instance Properties
    public let show: TVShow

    public init(show: TVShow) {
        self.show = show
    }

    public func quoteViewModelForQuoteAtIndexPath(_ indexPath: IndexPath) -> QuoteViewModel {
        let quote = getQuoteAtIndexPath(indexPath)
        return QuoteViewModel(quote: quote, show: show)
    }

    private func getQuoteAtIndexPath(_ indexPath: IndexPath) -> Quote {
        if query == "" {
            return show.quotes[indexPath.row]
        } else {
            return filteredQuotes[indexPath.row]
        }
    }

    public func getQuotes() -> [Quote] {
        if query == "" {
            return show.quotes
        } else {
            return filteredQuotes
        }
    }

    public var count: Int {
        if query == "" {
            return show.quotes.count
        } else {
            return filteredQuotes.count
        }
    }

    private func performSearch() {

        self.filteredQuotes = show.quotes.filter({(queryQuote: Quote) -> Bool in
            return queryQuote.quote.lowercased().contains(self.query.lowercased()) || queryQuote.quoter.lowercased().contains(self.query.lowercased())
        })

    }

}
