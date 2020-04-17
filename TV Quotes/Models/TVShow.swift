//
//  TVShow.swift
//  TV Quotes
//
//  Created by Omar Abbasi on 2018-07-23.
//  Copyright © 2018 Omar Abbasi. All rights reserved.
//

import Foundation
import UIKit

public struct TVShow: Codable {

    var name: String
    var image: String
    var quotes: [Quote]

    private enum CodingKeys: String, CodingKey {
        case name
        case image
        case quotes
    }

}
