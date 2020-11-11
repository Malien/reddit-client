import Foundation

// MARK: Misc extensions
extension Array {
    var slice: ArraySlice<Element> { self[startIndex...endIndex] }
}

// TODO: Add timed expiration
/// Expected to be used with value types as keys are being wrapped into class wrappers
struct Cache<Key, Entity>: EventSource where Key: Hashable {

    // MARK: Inner types
    enum Event {
        case removed(key: Key)
        case updated(key: Key, newValue: Entity)
    }

    typealias Listener = (ObservedEntity.EntityChangeEvent) -> Void
    
    typealias SubID = SubscriptionID<Self>

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
        private(set) var item: Entity?
        let key: Key
        
        enum EntityChangeEvent {
            case added(Entity)
            case updated(newValue: Entity, oldValue: Entity)
            case removed(oldValue: Entity)
            case expired(oldValue: Entity)
        }
        
        typealias EE = EventEmitter<EntityChangeEvent, Cache<Key, Entity>>
        var eventEmitter: EE = EventEmitter(queue: ApplicationServices.cacheQueue)

        init(key: Key, item: Entity? = nil) {
            self.item = item
            self.key = key
        }

        func subscribe(_ listener: @escaping EE.Listener) -> EE.SubID {
            eventEmitter.subscribe(listener)
        }

        func unsubscribe(_ subscription: EE.SubID) {
            eventEmitter.unsubscribe(subscription)
        }

        func remove() {
            ApplicationServices.cacheQueue.async {
                guard let oldValue = self.item else { return }
                self.item = nil
                self.eventEmitter.emit(event: .removed(oldValue: oldValue))
            }
        }

        func update(newValue: Entity) {
            ApplicationServices.cacheQueue.async {
                self.item = newValue
                if let oldValue = self.item {
                    self.eventEmitter.emit(event: .updated(newValue: newValue, oldValue: oldValue))
                } else {
                    self.eventEmitter.emit(event: .added(newValue))
                }
            }
        }

        func expire() {
            ApplicationServices.cacheQueue.async {
                guard let oldValue = self.item else { return }
                self.item = nil
                self.eventEmitter.emit(event: .removed(oldValue: oldValue))
            }
        }

    }

    private final class CacheDelegate: NSObject, NSCacheDelegate {
        @ThreadSafe(queueTarget: ApplicationServices.cacheQueue)
        var keys = Set<Key>()

        func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
            guard let entry = obj as? ObservedEntity else { return }
            entry.expire()
            $keys.mutate { $0.remove(entry.key) }
        }
    }

    // MARK: Actual implementation

    @ThreadSafe(
        wrappedValue: NSCache<WrappedKey, ObservedEntity>(), queueTarget: ApplicationServices.cacheQueue)
    private var storage
    private let delegate = CacheDelegate()
    private var eventEmitter = EventEmitter<Event, Self>(queue: ApplicationServices.cacheQueue)

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
                if entry != nil {
                    entry!.remove()
                    eventEmitter.emit(event: .removed(key: key))
                }
                self[entryFor: wrapped] = nil
                //                removeEntry(forKey: wrapped)
                return
            }
            let previous = entry ?? ObservedEntity(key: key)
            delegate.keys.insert(key)
            previous.update(newValue: newValue)
            eventEmitter.emit(event: .updated(key: key, newValue: newValue))
            self[entryFor: wrapped] = previous
            //            setEntry(previous, forKey: wrapped)
        }
    }

    mutating func subscribe(to key: Key, callback: @escaping Listener) -> SubID {
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

    mutating func unsubscribe(from key: Key, subscription: SubID) {
        storage.object(forKey: WrappedKey(key))?.unsubscribe(subscription)
    }
    
    mutating func subscribe(_ callback: @escaping (Event) -> Void) -> SubID {
        eventEmitter.subscribe(callback)
    }
    
    mutating func unsubscribe(_ subscription: SubID) {
        eventEmitter.unsubscribe(subscription)
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
