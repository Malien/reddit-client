import Foundation

@propertyWrapper class ThreadSafe<T> {
    let queue: DispatchQueue
    var value: T

    var projectedValue: ThreadSafe<T> { self }

    var wrappedValue: T {
        get {
            queue.sync { value }
        }
        set {
            queue.async { self.value = newValue }
        }
    }

    init(wrappedValue: T, qos: DispatchQoS = .utility, queueTarget: DispatchQueue? = nil) {
        self.value = wrappedValue
        self.queue = DispatchQueue(
            label: "ua.edu.ukma.ios.ThreadSafe", qos: qos, target: queueTarget)
    }

    func mutate(_ mutation: @escaping (inout T) -> Void) {
        queue.async { mutation(&self.value) }
    }
}
