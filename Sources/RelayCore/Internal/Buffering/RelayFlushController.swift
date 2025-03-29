import Foundation
import UIKit

// TODO: - This will need to be refactored so it is testable

final class RelayFlushController {
    private var timer: Timer?

    func startFlushTimer(buffer: RelayEventBuffer) {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            buffer.flush()
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification, 
            object: nil, 
            queue: nil
        ) { _ in
            buffer.flush()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
