//
//  Constants.swift
//  ImageFeed
//
//  Created by Максим Бабкин on 26.09.2024.
//

import UIKit

enum Constants {
    static let AccessKey = "WCq3ovUa8ZGsbglyGrjzfEg0x25mQGkrRGmRJyNrgfw"
    static let SecretKey = "RNrdw9mpZNXejwvzqcHePqIhwpBgoS2p3K1lNgm65as"
    static let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let AccessScope = "public+read_user+write_likes"
    static let DefaultBaseURL: URL = .init(string: "https://api.unsplash.com")!
}
