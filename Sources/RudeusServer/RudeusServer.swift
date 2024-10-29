import Logging

// MARK: - Rudeus

/// Runs the Rudeus server.
///
/// - Parameter
///   - host: The server host.
///   - port: The server port.
public func rudeus(host: String, port: Int) async throws {
  LoggingSystem.bootstrapWithRudeus()
  #if DEBUG
    let env = try await RudeusServerEnvironment.debug(host: host, port: port)
  #else
    let env = try await RudeusServerEnvironment.production(host: host, port: port)
  #endif
  let application = RudeusApplication(environment: env)
  try await application.runService()
}
