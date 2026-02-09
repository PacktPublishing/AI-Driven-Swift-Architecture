//
//  File.swift
//  Data
//
//  Created by Brahim Lamri on 22/08/2025.
//

import Foundation

import DIAbstraction

import UserAbstraction

public extension DIContainer {

    @MainActor static func registerUserService() {

        DIContainer.shared.register(UserService.self) { _ in

            UserService()
        }
    }
}

extension DIContainer {

    @MainActor public static func registerUserRepository() {

        DIContainer.shared.register(UserRepositoryProtocol.self) { _ in

            let service = DIContainer.shared.resolve(UserService.self)

            return UserRepository(userService: service!)
        }
    }
}
