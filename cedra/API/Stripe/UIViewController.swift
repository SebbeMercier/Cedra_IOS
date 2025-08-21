//
//  UIViewController.swift
//  cedra
//
//  Created by Sebbe Mercier on 18/08/2025.
//

import UIKit
import SwiftUI
import Stripe

extension View {
    func getRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
        return scene.windows.first?.rootViewController
    }
}


extension UIViewController: STPAuthenticationContext {
    public func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}
