//
//  TVShowViewModel.swift
//  TV Quotes
//
//  Created by Omar Abbasi on 2018-07-23.
//  Copyright © 2018 Omar Abbasi. All rights reserved.
//

import UIKit

//swiftlint:disable trailing_whitespace

protocol RefreshDelegate: class {
    func shouldRefresh()
}

public final class TVShowViewModel {

    public var shows = [TVShow]()
    weak var delegate: RefreshDelegate?
    var userDefaults = UserDefaults.standard
    var currentVersion: Double?
    let propertyKeys = PropertyKeys()

    init() {
        loadEverything()
    }
    
    func loadEverything() {
        let isConnected = Reachability.isConnectedToNetwork()
        userDefaults.set(isConnected, forKey: propertyKeys.isLive)
        
        currentVersion = userDefaults.double(forKey: propertyKeys.currentVersion)
        
        if isConnected {
            getRemoteQuotes()
        } else {
            if currentVersion == nil {
                // first launch with no internet
                let title = "No Internet Available"
                let message = "For the first launch, it is necessary that you connect to the internet to initially download the quotes. They can then be used offline."
                let firstLaunchAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let firstLaunchOkayAction = UIAlertAction(title: "A-Okay", style: .default, handler: nil)
                let firstLaunchRetryAction = UIAlertAction(title: "Retry", style: .default) { (_) in
                    self.loadEverything()
                }
                firstLaunchAlert.addAction(firstLaunchOkayAction)
                firstLaunchAlert.addAction(firstLaunchRetryAction)
                // TODO:
                // send through protocol here
            } else {
                getLocallyStoredQuotes()
            }
        }
        
    }

    private func getRemoteQuotes() {

        let urlPath = "https://tvquotes99.firebaseio.com/.json"
        guard let url = URL(string: urlPath) else { return }
        fetchData(with: url) { (data, _, _) in

            guard let data = data else { return }
            do {

                let json = try JSON(data: data)
                
                // let latestVersion = json["currentVersion"].doubleValue
                
                if self.currentVersion == nil {
                    // first launch
                    self.currentVersion = json["version"].doubleValue
                    self.userDefaults.set(self.currentVersion, forKey: self.propertyKeys.currentVersion)
                }
                
                // self.currentVersion! < latestVersion && shouldUpdate
                self.handleQuotesJSON(with: json, true)

            } catch {
                print("caught remote error")
            }

        }

    }

    func getLocallyStoredQuotes() {

        guard let storedQuotes = userDefaults.data(forKey: self.propertyKeys.quotes) else { return }
        do {

            let json = try JSON(data: storedQuotes)
            handleQuotesJSON(with: json, false)

        } catch {
            print("caught error")
        }

    }

    func handleQuotesJSON(with: JSON, _ shouldUpdate: Bool) {
        
        let json = with
        var tvShows = [TVShow]()
        
        // go inside shows
        for show in json["shows"].arrayValue {
            
            // get showName (key) and quotes (of JSON type array)
            for (showName, info):(String, JSON) in show {
                
                var showQuotes = [Quote]()
                
                // get quotes
                for quote in info["quotes"].arrayValue {
                    // quote is the json value of shows
                    let newQuote = Quote(quoter: quote["quoter"].stringValue, quote: quote["quote"].stringValue)
                    showQuotes.append(newQuote)
                }
                guard let imageURL = URL(string: info["image"].stringValue) else { return }
                let showImage = self.getImage(with: imageURL)
                
                let newShow = TVShow(name: showName, image: showImage, quotes: showQuotes)
                tvShows.append(newShow)
                
            }
        }
        
        if shouldUpdate {
            let quoterNames = json["names"].arrayValue.map({ $0.stringValue })
            self.userDefaults.set(quoterNames, forKey: self.propertyKeys.names)
            // TODO:
            // use nskeyarchiver
            // self.userDefaults.set(tvShows, forKey: self.propertyKeys.quotes)
        }
        
        self.shows = tvShows
        DispatchQueue.main.async {
            self.delegate?.shouldRefresh()
        }
        
    }

    private func getImage(with url: URL) -> UIImage {

        do {
            let data = try Data(contentsOf: url)
            guard let image = UIImage(data: data) else { return UIImage(named: "shuffle")! }
            return image
        } catch {
            return UIImage(named: "shuffle")!
        }

    }

    private func fetchData(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {

        let task = URLSession.shared
        let request = URLRequest(url: url)
        task.dataTask(with: request) { (data, response, error) in
            completionHandler(data, response, error)
        }.resume()

    }

    public func quoteListViewModelForTVShowAtIndexPath(_ indexPath: IndexPath) -> QuoteListViewModel {
        let show = getTVShowAtIndexPath(indexPath)
        return QuoteListViewModel(show: show)
    }

    private func getTVShowAtIndexPath(_ indexPath: IndexPath) -> TVShow {
        return shows[indexPath.row]
    }

    public var count: Int {
        return shows.count
    }

}
