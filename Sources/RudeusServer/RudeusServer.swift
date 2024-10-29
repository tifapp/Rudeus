import Hummingbird
import JWTKit
import Logging

private let logger = Logger(label: "rudeus.main")

// MARK: - Rudeus

/// Runs the Rudeus server.
///
/// - Parameter env: The ``RudeusServerEnvironment`` to use.
public func rudeus(environment env: RudeusServerEnvironment) async throws {
  logger.info("Started Rudeus Server on \(env.host):\(env.port)")
}
