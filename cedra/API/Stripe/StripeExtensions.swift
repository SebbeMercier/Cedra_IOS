//
//  StripeExtensions.swift
//  cedra
//
//  Created by Sebbe Mercier on 20/10/2025.
//

import UIKit
import Stripe

extension UIViewController: STPAuthenticationContext {
    public func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}
