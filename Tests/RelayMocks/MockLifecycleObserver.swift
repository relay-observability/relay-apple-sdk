import RelayCommon

class MockLifecycleObserver: LifecycleObserver {
    private var handler: (() -> Void)?
    
    func observeWillResignActive(_ callback: @escaping () -> Void) {
        handler = callback
    }

    func simulateWillResignActive() {
        handler?()
    }
}
