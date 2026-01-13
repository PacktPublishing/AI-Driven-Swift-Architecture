import Foundation

import DIAbstraction

import AnalyticsAbstraction

extension DIContainer {

    @MainActor
    public static func registerSendProductDetailAnalyticsDataUseCase() {

        DIContainer.shared.register(SendProductDetailAnalyticsDataUsecaseProtocol.self) { _ in

            let wrapper = DIContainer.shared.resolve(AnalyticsWrapperProtocol.self)

            return SendProductDetailAnalyticsDataUseCase(analyticsWrapper: wrapper!)
        }

    }
}
