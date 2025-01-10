// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftyStoreKit
import TPInAppReceipt

// 定义环境枚举，用于区分沙盒和生产环境
public enum Environment {
    case sandbox
    case production
}

// 错误枚举，用于处理购买或恢复时的错误
public enum IAPError: Error {
    case purchaseFailed(code: Int, message: String)
    case restoreFailed(code: Int, message: String)
}

// 购买回调闭包类型定义
public typealias PurchaseCompletionHandler = (Result<String, IAPError>) -> Void

// ReStoreKit SDK 主类
public class ReStoreKit {
    public static let shared = ReStoreKit()
    
    private var products: [StoreModel] = []
    private var environment: Environment = .production
    
    private init() {}
    
    // 初始化 SDK，传入产品列表和环境配置
    public func configure(with products: [StoreModel], environment: Environment = .production) {
        self.products = products
        self.environment = environment
        IAPManager.shared.setup(products: products, environment: environment)
    }
    
    // 购买商品
    public func purchase(product: StoreModel, completion: @escaping PurchaseCompletionHandler) {
        IAPManager.shared.purchaseCoinsForPixel(product: product, completion: completion)
    }
    
    // 恢复购买
    public func restorePurchases(completion: @escaping PurchaseCompletionHandler) {
        IAPManager.shared.restore(completion: completion)
    }
    
    // 获取订阅过期时间
    public func getSubscriptionExpirationDate() -> String? {
        return IAPManager.shared.getSubscriptionExpirationDate()
    }
    
    // 检查是否有有效订阅
    public func isSubscribed() -> Bool {
        return IAPManager.shared.isSubscribed
    }
}
