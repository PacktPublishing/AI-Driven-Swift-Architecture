import Foundation

import AnalyticsAbstraction

import DIAbstraction

final class SendProductDetailAnalyticsDataUseCase: SendProductDetailAnalyticsDataUsecaseProtocol {

    private let analyticsWrapper: AnalyticsWrapperProtocol

    init(analyticsWrapper: AnalyticsWrapperProtocol) {

        self.analyticsWrapper = analyticsWrapper
    }

    func start(data: String) {

        analyticsWrapper.trackEvent(data)
    }
}
