public protocol CriticalErrorHandler: AnyObject {
    func handleCriticalError(_ error: Error)
}
