//
//  File.swift
//  ReStoreKit
//
//  Created by 喻铭悟 on 2025/1/10.
//

import Foundation

// StoreModel 需要根据实际产品信息实现
public struct StoreModel {
    public let productID: String
    public let productName: String
    
    // 自定义初始化器，并将其设为 public
    public init(productID: String, productName: String) {
        self.productID = productID
        self.productName = productName
    }
}
