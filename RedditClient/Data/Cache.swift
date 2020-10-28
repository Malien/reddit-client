import Foundation

// MARK: Misc extensions
extension Array {
    var slice: ArraySlice<Element> { self[startIndex...endIndex] }
}

extension Array where Element: AnyObject {
    func index(of element: Element) -> Index? {
        for (i, value) in self.enumerated() {
            if value === element {
                return i
            }
        }
        return nil
    }

    mutating func remove(element: Element) {
        guard let idx = index(of: element) else { return }
        remove(at: idx)
    }
}

fileprivate enum CacheQueue {
    /// Unfourtunatelly all caches HAVE TO share a single queue to be able to use property wrappers with ability to flatten queues
    static let cacheQueue = DispatchQueue(label: "ua.edu.ukma.ios.Cache", qos: .utility)
}

// TODO: Add timed expiration
/// Expected to be used with value types as keys are being wrapped into class wrappers
struct Cache<Key, Entity> where Key: Hashable {

    // MARK: Inner types
    enum Event {
        case added(Entity)
        case updated(newValue: Entity, oldValue: Entity)
        case removed(oldValue: Entity)
        case expired(oldValue: Entity)
    }

    typealias Listener = (Event) -> Void

    struct SubscriptionID: Hashable {
        private let id: Int
        var next: SubscriptionID { SubscriptionID(id: id + 1) }
        static var firstID: SubscriptionID { SubscriptionID(id: 0) }
    }

    final class WrappedKey: NSObject {
        let key: Key
        init(_ key: Key) {
            self.key = key
        }

        override var hash: Int { key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else { return false }
            return value.key == key
        }
    }

    final class ObservedEntity {
        let queue = DispatchQueue(
            label: "ua.edu.ukma.ios.Cache<\(Entity.self)>.ObservedEntity",
            target: CacheQueue.cacheQueue)
        private(set) var item: Entity?
        let key: Key
        private var listeners: [SubscriptionID: Listener] = [:]
        private var currentID = SubscriptionID.firstID

        init(key: Key, item: Entity? = nil) {
            self.item = item
            self.key = key
        }

        func subscribe(_ listener: @escaping Listener) -> SubscriptionID {
            return queue.sync {
                let sub = currentID
                listeners[sub] = listener
                currentID = currentID.next
                return sub
            }
        }

        func unsubscribe(_ subscription: SubscriptionID) {
            queue.async {
                self.listeners.removeValue(forKey: subscription)
            }
        }

        func fire(event: Event) {
            for listener in listeners.values {
                queue.async {
                    listener(event)
                }
            }
        }

        func remove() {
            queue.async {
                guard let oldValue = self.item else { return }
                self.item = nil
                self.fire(event: .removed(oldValue: oldValue))
            }
        }

        func update(newValue: Entity) {
            queue.async {
                self.item = newValue
                if let oldValue = self.item {
                    self.fire(event: .updated(newValue: newValue, oldValue: oldValue))
                } else {
                    self.fire(event: .added(newValue))
                }
            }
        }

        func expire() {
            queue.async {
                guard let oldValue = self.item else { return }
                self.item = nil
                self.fire(event: .removed(oldValue: oldValue))
            }
        }

    }

    private final class CacheDelegate: NSObject, NSCacheDelegate {
        @ThreadSafe(wrappedValue: Set<Key>(), queueTarget: CacheQueue.cacheQueue) var keys

        func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
            guard let entry = obj as? ObservedEntity else { return }
            entry.expire()
            $keys.mutate { $0.remove(entry.key) }
        }
    }

    // MARK: Actual implementation

    @ThreadSafe(
        wrappedValue: NSCache<WrappedKey, ObservedEntity>(), queueTarget: CacheQueue.cacheQueue)
    private var storage
    private let delegate = CacheDelegate()

    private subscript(entryFor key: WrappedKey) -> ObservedEntity? {
        get {
            storage.object(forKey: key)
        }
        set {
            if let newValue = newValue {
                $storage.mutate { $0.setObject(newValue, forKey: key) }
            } else {
                $storage.mutate { $0.removeObject(forKey: key) }
            }
        }
    }

    init() {
        storage.delegate = self.delegate
    }

    subscript(key: Key) -> Entity? {
        get {
            storage.object(forKey: WrappedKey(key))?.item
        }
        set {
            let wrapped = WrappedKey(key)
            let entry = storage.object(forKey: wrapped)
            guard let newValue = newValue else {
                entry?.remove()
                self[entryFor: wrapped] = nil
                //                removeEntry(forKey: wrapped)
                return
            }
            let previous = entry ?? ObservedEntity(key: key)
            delegate.keys.insert(key)
            previous.update(newValue: newValue)
            self[entryFor: wrapped] = previous
            //            setEntry(previous, forKey: wrapped)
        }
    }

    mutating func subscribe(to key: Key, callback: @escaping Listener) -> SubscriptionID {
        let wrapped = WrappedKey(key)
        if let entry = storage.object(forKey: wrapped) {
            return entry.subscribe(callback)
        } else {
            let entry = ObservedEntity(key: key)
            let subscription = entry.subscribe(callback)
            //                setEntry(entry, forKey: wrapped)
            self[entryFor: wrapped] = entry
            return subscription
        }
    }

    mutating func unsubscribe(from key: Key, subscription: SubscriptionID) {
        storage.object(forKey: WrappedKey(key))?.unsubscribe(subscription)
    }
}

// MARK: Serialization of ObservedEntity
extension Cache.ObservedEntity: Codable where Key: Codable, Entity: Codable {
    enum CodingKeys: String, CodingKey {
        case item
        case key
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(item, forKey: .item)
        try container.encode(key, forKey: .key)
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let item = try container.decode(Entity?.self, forKey: .item)
        let key = try container.decode(Key.self, forKey: .key)
        self.init(key: key, item: item)
    }
}

// MARK: Serialization of Cache
extension Cache: Codable where Key: Codable, Entity: Codable {
    private struct KeyValuePair: Codable {
        let key: Key
        let value: Entity?
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let values = delegate.keys
            .compactMap { key in storage.object(forKey: WrappedKey(key)) }
        try container.encode(values)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        for entry in try container.decode([ObservedEntity].self) {
            self[entry.key] = entry.item
        }
    }
}
