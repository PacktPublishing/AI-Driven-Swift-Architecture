import Foundation

import AnalyticsAbstraction

import DIAbstraction

public final class SendProductDetailAnalyticsDataUseCase: SendProductDetailAnalyticsDataUsecaseProtocol {

    private let analyticsWrapper: AnalyticsWrapperProtocol

    public init(analyticsWrapper: AnalyticsWrapperProtocol) {

        self.analyticsWrapper = analyticsWrapper
    }

    public func start(data: String) {

        analyticsWrapper.trackEvent(data)
    }
}
