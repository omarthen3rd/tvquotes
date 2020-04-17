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
            getRemoteNames()
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
    
    private func getRemoteNames() {
        
        let urlPath = "https://tvquotes99.firebaseio.com/names/.json"
        guard let url = URL(string: urlPath) else { return }
        fetchData(with: url) { (data, _, _) in

            guard let data = data else { return }
            do {

                let names = try JSONDecoder().decode([String].self, from: data)
                self.userDefaults.set(names, forKey: self.propertyKeys.names)
                
            } catch {
                print("caught remote error")
            }

        }

        
    }

    private func getRemoteQuotes() {

        let urlPath = "https://tvquotes99.firebaseio.com/shows/.json"
        guard let url = URL(string: urlPath) else { return }
        fetchData(with: url) { (data, _, _) in

            guard let data = data else { return }
            do {

                self.handleQuotesJSON(with: data, false)
                let json = try JSON(data: data)
                                
                if self.currentVersion == nil {
                    self.currentVersion = json["version"].doubleValue
                    self.userDefaults.set(self.currentVersion, forKey: self.propertyKeys.currentVersion)
                }
                
            } catch {
                print("caught remote error")
            }

        }

    }

    func getLocallyStoredQuotes() {

        guard let storedQuotes = userDefaults.data(forKey: self.propertyKeys.quotes) else { return }
        handleQuotesJSON(with: storedQuotes, false)

    }

    func handleQuotesJSON(with: Data, _ shouldUpdate: Bool) {
        
        let data = with
        var tvShows = [TVShow]()
        
        do {
            tvShows = try JSONDecoder().decode([TVShow].self, from: data)
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
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
