import Hummingbird
import Logging
import WPFoundation

// MARK: - RudeusApplication

/// The Hummingbird application for Rudeus.
public struct RudeusApplication: Sendable {
  public let environment: RudeusServerEnvironment
  public let logger = Logger(label: "rudeus.application")

  public init(environment: RudeusServerEnvironment) {
    self.environment = environment
  }
}

// MARK: - ApplicationProtocol

extension RudeusApplication: ApplicationProtocol {
  public var responder: some HTTPResponder<RudeusRequestContext> {
    let router = Router(context: RudeusRequestContext.self)
    router.add(middleware: RudeusAuthenticationMiddleware(keys: self.environment.keys))
      .group("api")
      .post("register") { try await self.register(request: $0, context: $1) }
      .post("pattern") { try await self.editPattern(request: $0, context: $1) }
      .get("pattern") { _, _ in try await self.patterns() }
    return router.buildResponder()
  }

  public var configuration: ApplicationConfiguration {
    ApplicationConfiguration(
      address: .hostname(self.environment.host, port: self.environment.port),
      serverName: "Rudeus"
    )
  }
}

// MARK: - Register

extension RudeusApplication {
  private func register(
    request: Request,
    context: Context
  ) async throws -> EditedResponse<RudeusRegisterResponse> {
    let request = try await request.decode(as: RudeusRegisterRequest.self, context: context)
    let user = try await self.environment.database.createUser(named: request.name)
    let token = try await self.environment.keys.sign(user)
    return EditedResponse(
      status: .created,
      response: RudeusRegisterResponse(id: user.id, name: user.name, token: token)
    )
  }
}

// MARK: - Edit Pattern

extension RudeusApplication {
  private func editPattern(
    request: Request,
    context: Context
  ) async throws -> EditedResponse<RudeusPattern> {
    let user = try context.requireUser()
    let request = try await request.decode(as: RudeusSavePatternRequest.self, context: context)
    let pattern = RudeusPattern(
      id: request.id ?? UUIDV7(),
      name: request.name,
      user: user,
      ahapPattern: request.ahapPattern,
      platform: request.platform
    )
    try await self.environment.database.save(pattern: pattern)
    try await self.environment.slackClient.send(
      message: .patternShared(channelId: self.environment.slackChannelId, pattern)
    )
    return EditedResponse(status: request.id != nil ? .ok : .created, response: pattern)
  }
}

// MARK: - Patterns

extension RudeusApplication {
  private func patterns() async throws -> EditedResponse<RudeusPatternsResponse> {
    let patterns = try await self.environment.database.patterns()
    return EditedResponse(status: .ok, response: RudeusPatternsResponse(patterns: patterns))
  }
}
