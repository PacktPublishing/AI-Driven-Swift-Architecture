//
//  File.swift
//  Data
//
//  Created by Brahim Lamri on 22/08/2025.
//

import Foundation

import DIAbstraction

import ProductAbstraction

extension DIContainer {

    @MainActor public static func registerProductService() {

        DIContainer.shared.register(ProductService.self) { _ in

            ProductService()
        }
    }
}


extension DIContainer {

    @MainActor public static func registerProductRepository() {

        DIContainer.shared.register(ProductRepositoryProtocol.self) { _ in

            let service = DIContainer.shared.resolve(ProductService.self)

            return ProductRepository(productService: service!)
        }
    }
}
