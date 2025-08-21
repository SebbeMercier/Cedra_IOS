import Stripe
import StripePaymentSheet
import UIKit

class StripeManager {
    static let shared = StripeManager()
    private var paymentSheet: PaymentSheet?

    private init() {}
    
    func preparePaymentSheet(clientSecret: String) {
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Cedra"
        configuration.returnURL = "cedra://stripe-redirect" // Obligatoire si tu actives certains moyens de paiement
        
        // ➕ Optionnel : désactive les méthodes différées si jamais tu les actives
        configuration.allowsDelayedPaymentMethods = false

        self.paymentSheet = PaymentSheet(
            paymentIntentClientSecret: clientSecret,
            configuration: configuration
        )
    }
    
    func presentPaymentSheet(from viewController: UIViewController) {
        guard let paymentSheet = paymentSheet else {
            print("⚠️ PaymentSheet non prêt")
            return
        }

        paymentSheet.present(from: viewController) { result in
            switch result {
            case .completed:
                print("✅ Paiement réussi")
            case .canceled:
                print("⚠️ Paiement annulé")
            case .failed(let error):
                print("❌ Paiement échoué : \(error.localizedDescription)")
            }
        }
    }
}
