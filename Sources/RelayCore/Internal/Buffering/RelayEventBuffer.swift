import Foundation

// TODO: Make the capcity configurable and make this queue testable

final class RelayEventBuffer {
    private let ringBuffer = RingBuffer<RelayEvent>(capacity: 1024)
    private let queue = DispatchQueue(label: "com.relay.buffer", qos: .background)

    func add(_ event: RelayEvent) {
        queue.async {
            self.ringBuffer.append(event)
        }
    }

    func flush() {
        queue.async {
            let snapshot = self.ringBuffer.snapshot()
            self.ringBuffer.clear()
            RelayDiskWriter.write(events: snapshot)
        }
    }
}
