import Foundation
import Factory

// Factory provides Container.shared by default
// We maintain the DIContainer wrapper for architectural consistency
@MainActor
public class DIContainer {
    public static let shared = Container.shared
}
