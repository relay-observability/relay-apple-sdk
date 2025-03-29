public protocol LifecycleObserver {
    func observeWillResignActive(_ handler: @escaping () -> Void)
}
