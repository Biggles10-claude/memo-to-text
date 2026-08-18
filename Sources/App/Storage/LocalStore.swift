import Foundation

/// Tiny on-device persistence (template t1): Codable values in
/// `UserDefaults`. This is the template's only storage — no files with
/// timestamps, no iCloud, no network — which is exactly what the
/// `PrivacyInfo.xcprivacy` manifest declares (UserDefaults, reason CA92.1).
struct LocalStore {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save<Value: Codable>(_ value: Value, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    func load<Value: Codable>(_ type: Value.Type, forKey key: String) -> Value? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
}
