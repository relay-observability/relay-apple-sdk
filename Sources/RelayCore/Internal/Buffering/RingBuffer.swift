import Foundation

final class RingBuffer<T> {
    private var buffer: [T?]
    private var head = 0
    private var count = 0
    private let capacity: Int

    init(capacity: Int) {
        self.capacity = capacity
        self.buffer = Array(repeating: nil, count: capacity)
    }

    func append(_ element: T) {
        buffer[head] = element
        head = (head + 1) % capacity
        if count < capacity {
            count += 1
        }
    }

    func snapshot() -> [T] {
        var result: [T] = []
        for i in 0..<count {
            let index = (head + capacity - count + i) % capacity
            if let element = buffer[index] {
                result.append(element)
            }
        }
        return result
    }

    func clear() {
        buffer = Array(repeating: nil, count: capacity)
        head = 0
        count = 0
    }
}
