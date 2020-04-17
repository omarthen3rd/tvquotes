//
//  QuoteViewModel.swift
//  TV Quotes
//
//  Created by Omar Abbasi on 2018-07-23.
//  Copyright © 2018 Omar Abbasi. All rights reserved.
//

import UIKit

// swiftlint:disable line_length

public final class QuoteViewModel {

    var names = [String]()

    // MARK: - Instance Properties
    public var quote: Quote
    public let show: TVShow

    private let showName: String
    private let quoteText: String
    private let quoterText: String
    private var didShuffle = false
    private var shuffleQuoteIndex = 0
    private let propertyKeys = PropertyKeys()
    private var userDefaults = UserDefaults.standard

    public init(quote: Quote, show: TVShow) {

        self.quote = quote
        self.show = show

        self.showName = show.name
        self.quoteText = quote.quote
        self.quoterText = quote.quoter

        self.getNames()
    }

    private func getFontSize() -> CGFloat {

        let deviceHeight = UIScreen.main.bounds.size.height

        // if device height is <= 568 (4" iPhone), then font size is 17 else 20
        return deviceHeight <= 568 ? 17 : 20

    }

    func getNames() {

        guard let storedNames = userDefaults.object(forKey: self.propertyKeys.names) as? [String] else { return }
        self.names = storedNames
    }

    func loadShuffledQuote(_ origin: Bool = true) -> Quote {

        var quotesShuffled = self.show.quotes

        if origin {
            quotesShuffled.shuffle()
            self.didShuffle = true
            shuffleQuoteIndex += 1
            return quotesShuffled[shuffleQuoteIndex]
        } else {
            if shuffleQuoteIndex == (quotesShuffled.count - 1) {
                return quotesShuffled[quotesShuffled.count - 1]
            } else {
                shuffleQuoteIndex += 1
                return quotesShuffled[shuffleQuoteIndex]
            }
        }

    }

    public func getQuoteString(_ isRandom: Bool = false) -> NSMutableAttributedString {

        if isRandom {
            self.quote = (shuffleQuoteIndex == 0) ? loadShuffledQuote(true) : loadShuffledQuote(false)
        }

        let currentFontSize = getFontSize()

        let attrString = NSMutableAttributedString(string: quote.quote)
        attrString.setSizeForText(quote.quote, with: UIFont(name: "NewYorkSmall-Regular", size: currentFontSize)!)

        for name in names {

            var range: NSRange = (quote.quote as NSString).range(of: "\(name):")

            while range.location != NSNotFound {
                attrString.boldTextIn(range, size: currentFontSize)

                let searchRange = NSMakeRange(range.location + range.length, (quote.quote as NSString).length - range.length - range.location)
                range = (quote.quote as NSString).range(of: "\(name):", options: NSString.CompareOptions.caseInsensitive, range: searchRange)
            }

        }
        return attrString
    }

    func getQuoterString(_ isRandom: Bool = false) -> NSMutableAttributedString {

        let addOn = "\n\(showName.uppercased())"
        let quoterText = quote.quoter.uppercased() + addOn
        let attrQuoterString = NSMutableAttributedString(string: quoterText)
        attrQuoterString.setSizeForText(addOn, with: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular))
        attrQuoterString.setSizeForText(quoterText, with: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.semibold))

        return attrQuoterString

    }

}
