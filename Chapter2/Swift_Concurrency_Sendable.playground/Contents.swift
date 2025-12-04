import Synchronization

final class Counter: Sendable {
    private let value = Mutex<Int>(0)

    func increment() {
        value.withLock { $0 += 1 }
    }

    func getValue() -> Int {
        value.withLock { $0 }

    }
}

let counter = Counter()

Task.detached {
    for _ in 0..<1000 {
        counter.increment()
    }
}

Task.detached {
    for _ in 0..<1000 {
        counter.increment()
    }
}

Task {
    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
    let finalValue =  counter.getValue()
    print("Final counter value: \(finalValue)")
}








