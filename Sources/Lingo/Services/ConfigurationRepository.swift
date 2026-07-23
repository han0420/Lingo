import Foundation

struct ConfigurationRepository {
    static let storageKey = "lingo.configuration.v1"
    private let defaults: UserDefaults
    private let availableSources: () -> [InputSourceDescriptor]

    init(
        defaults: UserDefaults = .standard,
        availableSources: @escaping () -> [InputSourceDescriptor] = { InputSourceService().availableSources() }
    ) {
        self.defaults = defaults
        self.availableSources = availableSources
    }

    func load() -> LingoConfiguration {
        guard let data = defaults.data(forKey: Self.storageKey),
              let configuration = try? JSONDecoder().decode(LingoConfiguration.self, from: data) else {
            return InputSourcePreferenceResolver.migrate(.defaults, availableSources: availableSources())
        }
        return InputSourcePreferenceResolver.migrate(configuration, availableSources: availableSources())
    }

    func save(_ configuration: LingoConfiguration) throws {
        defaults.set(try JSONEncoder().encode(configuration), forKey: Self.storageKey)
    }
}
