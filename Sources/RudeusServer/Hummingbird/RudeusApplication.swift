import Hummingbird
import Logging

// MARK: - RudeusApplication

/// The Hummingbird application for Rudeus.
public struct RudeusApplication: Sendable {
  private let environment: RudeusServerEnvironment
  public let logger = Logger(label: "rudeus.application")

  public init(environment: RudeusServerEnvironment) {
    self.environment = environment
  }
}

// MARK: - ApplicationProtocol

extension RudeusApplication: ApplicationProtocol {
  public var responder: some HTTPResponder<RudeusRequestContext> {
    let router = Router(context: RudeusRequestContext.self)
    router.get("hello") { _, _ in "Hello" }
    return router.buildResponder()
  }

  public var configuration: ApplicationConfiguration {
    ApplicationConfiguration(
      address: .hostname(self.environment.host, port: self.environment.port),
      serverName: "Rudeus"
    )
  }
}
