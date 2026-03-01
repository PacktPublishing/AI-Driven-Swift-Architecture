import Foundation

import AnalyticsAbstraction

public final class AnalyticsWrapper: AnalyticsWrapperProtocol {

    public init() {}

    public func trackEvent(_ event: String) {
        print("Tracking event \(event)")
    }

}
