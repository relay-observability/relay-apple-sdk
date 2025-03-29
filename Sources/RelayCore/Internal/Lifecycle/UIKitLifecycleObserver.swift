#if canImport(UIKit)
import UIKit

public final class UIKitLifecycleObserver: LifecycleObserver {
    public init() {}

    public func observeWillResignActive(_ handler: @escaping () -> Void) {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: nil
        ) { _ in
            handler()
        }
    }
}
#endif
