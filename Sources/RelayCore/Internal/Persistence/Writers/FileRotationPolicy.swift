import Foundation

struct FileRotationPolicy {
    let maxSize: Int
    let maxEvents: Int

    func shouldRotate(
        currentSize: Int,
        currentEvents: Int,
        newDataSize: Int,
        newEventCount: Int
    ) -> Bool {
        currentSize + newDataSize > maxSize ||
            currentEvents + newEventCount > maxEvents
    }
}
