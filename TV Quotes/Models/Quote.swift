//
//  Quote.swift
//  TV Quotes
//
//  Created by Omar Abbasi on 2018-07-23.
//  Copyright © 2018 Omar Abbasi. All rights reserved.
//

import Foundation

public struct Quote: Codable {

    var quote: String
    var quoter: String

}

struct PropertyKeys {

    let isLive = "isLive"
    let currentVersion = "currentVersion"
    let isLatestVersion = "isLatestVersion"
    let names = "names"
    let quotes = "quotes"

}
