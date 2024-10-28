import Logging

private let logger = Logger(label: "rudeus.main")

/// Runs the Rudeus server.
///
/// - Parameters:
///   - host: The host name.
///   - port: The port.
public func rudeus(host: String, port: Int) async throws {
  LoggingSystem.bootstrapWithRudeus()
  logger.info("Started Rudeus", metadata: ["host": .string(host), "port": "\(port)"])
}
