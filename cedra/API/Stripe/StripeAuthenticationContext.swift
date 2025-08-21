//
//  StripeAuthenticationContext.swift
//  cedra
//
//  Created by Sebbe Mercier on 18/08/2025.
//

import UIKit
import Stripe

final class StripeAuthenticationContext: NSObject, STPAuthenticationContext {
    private weak var presentingViewController: UIViewController?

    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }

    func authenticationPresentingViewController() -> UIViewController {
        return presentingViewController!
    }
}
