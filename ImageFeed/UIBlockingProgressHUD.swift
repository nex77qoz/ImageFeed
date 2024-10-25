//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Максим Бабкин on 24.10.2024.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first { $0.isKeyWindow }
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}