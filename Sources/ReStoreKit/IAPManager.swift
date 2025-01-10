//
//  IAPManager.swift
//  ReStoreKit
//
//  Created by 喻铭悟 on 2025/1/10.
//

import Foundation
import SwiftyStoreKit
import TPInAppReceipt

// IAPManager 负责处理实际的 IAP 操作逻辑
class IAPManager {
    static let shared = IAPManager()
    
    var isSubscribed = false
    private var products: [StoreModel] = []
    private var environment: Environment = .production
    
    private init() {}

    // 初始化设置
    func setup(products: [StoreModel], environment: Environment) {
        self.products = products
        self.environment = environment
        reloadReceipt()
        
        // 完成交易并检查购买状态
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // 完成交易
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    // 重新加载收据
                    self.reloadReceipt()
                case .failed, .purchasing, .deferred:
                    break
                default:
                    break
                }
            }
        }

        // 获取产品信息
        let productIDs = Set(products.map { $0.productID })
        SwiftyStoreKit.retrieveProductsInfo(productIDs) { result in
            debugPrint("有效产品列表\(result.retrievedProducts)")
            debugPrint("无效产品列表\(result.invalidProductIDs)")
        }
        isSubscribed = isSubscriptionActive()
    }
    
    // 重新加载收据并检查订阅状态
    private func reloadReceipt() {
        InAppReceipt.refresh { [weak self] (error) in
            guard let self = self else { return }
            self.isSubscribed = self.isSubscriptionActive()
        }
    }
    
    // 检查订阅是否有效
    private func isSubscriptionActive() -> Bool {
        do {
            let receipt = try InAppReceipt.localReceipt()
            guard receipt.isValid else { return false }
            return receipt.hasActiveAutoRenewablePurchases
        } catch {
            return false
        }
    }
    
    // 获取订阅过期时间
    func getSubscriptionExpirationDate() -> String? {
        do {
            let receipt = try InAppReceipt.localReceipt()
            guard receipt.isValid else { return nil }
            guard let purchase = receipt.activeAutoRenewableSubscriptionPurchases.first else { return nil }
            
            if let expirationDate = purchase.subscriptionExpirationDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                return dateFormatter.string(from: expirationDate)
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    // 购买商品
    func purchaseCoinsForPixel(product: StoreModel, completion: @escaping PurchaseCompletionHandler) {
        if hasPurchaseProduct(product) {
            completion(.failure(.purchaseFailed(code: 1, message: "你已经订阅过此商品了。")))
        } else {
            SwiftyStoreKit.purchaseProduct(product.productID, quantity: 1, atomically: true) { result in
                switch result {
                case .success:
                    self.isSubscribed = true
                    completion(.success("购买成功"))
                case let .error(error):
                    let errorMessage: String
                    switch error.code {
                    case .paymentCancelled:
                        errorMessage = "用户取消"
                    case .cloudServiceNetworkConnectionFailed:
                        errorMessage = "网络连接失败，请稍后再试"
                    default:
                        errorMessage = error.localizedDescription
                    }
                    completion(.failure(.purchaseFailed(code: error.code.rawValue, message: errorMessage)))
                }
            }
        }
    }
    
    // 判断用户是否已经购买该商品
    func hasPurchaseProduct(_ storeModel: StoreModel) -> Bool {
        do {
            let receipt = try InAppReceipt.localReceipt()
            guard receipt.isValid else { return false }
            return receipt.hasActiveAutoRenewableSubscription(ofProductIdentifier: storeModel.productID, forDate: Date())
        } catch {
            return false
        }
    }
    
    // 恢复购买
    func restore(completion: @escaping PurchaseCompletionHandler) {
        SwiftyStoreKit.restorePurchases(atomically: false) { results in
            if results.restoreFailedPurchases.count > 0 {
                completion(.failure(.restoreFailed(code: 2, message: "恢复购买失败，请重试")))
            } else if results.restoredPurchases.count > 0 {
                self.isSubscribed = self.isSubscriptionActive()
                completion(.success("恢复购买成功"))
            } else {
                completion(.failure(.restoreFailed(code: 3, message: "没有可恢复的购买")))
            }
        }
    }
}
