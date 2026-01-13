import Foundation

import DIAbstraction

import AnalyticsAbstraction

extension DIContainer {

    @MainActor
    public static func registerAnalyticsWrapper() {

        DIContainer.shared.register(AnalyticsWrapperProtocol.self) { _ in

            AnalyticsWrapper()
        }
    }
}
