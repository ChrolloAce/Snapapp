import SuperwallKit
import StoreKit
import FirebaseAuth
import FirebaseFirestore

final class AppPurchaseController: PurchaseController {
    static let shared = AppPurchaseController()
    private let db = Firestore.firestore()
    
    func purchase(product: StoreProduct) async -> PurchaseResult {
        print("\n💰 PROCESSING PURCHASE:")
        print("Product ID: \(product.productIdentifier)")
        
        // Prevent concurrent purchases
        guard !UserDefaults.standard.bool(forKey: "isHandlingTransaction") else {
            print("⚠️ Already handling a transaction, skipping")
            return .pending
        }
        
        UserDefaults.standard.set(true, forKey: "isHandlingTransaction")
        UserDefaults.standard.synchronize()
        
        do {
            let products = try await Product.products(for: [product.productIdentifier])
            guard let storeKitProduct = products.first else {
                UserDefaults.standard.set(false, forKey: "isHandlingTransaction")
                UserDefaults.standard.synchronize()
                return .failed(NSError(domain: "PurchaseController",
                                    code: 1,
                                    userInfo: [NSLocalizedDescriptionKey: "Product not found"]))
            }
            
            let result = try await storeKitProduct.purchase()
            
            // Mark transaction as complete
            UserDefaults.standard.set(false, forKey: "isHandlingTransaction")
            UserDefaults.standard.synchronize()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    return .purchased
                case .unverified:
                    return .failed(NSError(domain: "PurchaseController",
                                        code: 2,
                                        userInfo: [NSLocalizedDescriptionKey: "Purchase verification failed"]))
                }
            case .pending:
                return .pending
            case .userCancelled:
                return .cancelled
            }
        } catch {
            return .failed(error)
        }
    }
    
    func restorePurchases() async -> RestorationResult {
        do {
            try await AppStore.sync()
            
            for await result in Transaction.currentEntitlements {
                if case .verified = result {
                    return .restored
                }
            }
            
            return .failed(nil)
        } catch {
            return .failed(error)
        }
    }
} 