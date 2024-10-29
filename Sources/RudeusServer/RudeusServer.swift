import Hummingbird
import JWTKit
import Logging

private let logger = Logger(label: "rudeus.server")

// MARK: - Rudeus

/// Runs the Rudeus server.
///
/// - Parameter env: The ``RudeusServerEnvironment`` to use.
public func rudeus(environment env: RudeusServerEnvironment) async throws {
  let router = Router(context: RudeusRequestContext.self)
  let application = Application(
    router: router,
    configuration: ApplicationConfiguration(
      address: .hostname(env.host, port: env.port),
      serverName: "rudeus"
    ),
    logger: logger
  )
  try await application.run()
}
