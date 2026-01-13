import Foundation

import AnalyticsAbstraction

final class AnalyticsWrapper: AnalyticsWrapperProtocol {

    init() {}

    func trackEvent(_ event: String) {
        print("Tracking event \(event)")
    }

}
