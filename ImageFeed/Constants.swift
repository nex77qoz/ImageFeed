import UIKit

enum Constants {
    static let accessKey = "WCq3ovUa8ZGsbglyGrjzfEg0x25mQGkrRGmRJyNrgfw"
    static let secretKey = "RNrdw9mpZNXejwvzqcHePqIhwpBgoS2p3K1lNgm65as"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Не удалось создать URL")
        }
        return url
    }()
}
