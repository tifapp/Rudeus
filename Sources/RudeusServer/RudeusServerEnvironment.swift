import Hummingbird
import JWTKit

// MARK: - RudeusServerEnvironment

public struct RudeusServerEnvironment: Sendable {
  /// The host for the HTTP server.
  public var host: String

  /// The port of the HTTP server.
  public var port: Int

  /// The main ``RudeusDatabase`` for the server.
  public var database: RudeusDatabase

  /// The main ``RudeusSlackClient`` for the server.
  public var slackClient: any RudeusSlackClient

  /// The slack channel id that the server should send messages to.
  public var slackChannelId: String

  /// The main `JWTKeyCollection` the server should use to sign JWTs.
  public var keys: JWTKeyCollection

  public init(
    host: String,
    port: Int,
    database: RudeusDatabase,
    slackClient: any RudeusSlackClient,
    slackChannelId: String,
    keys: JWTKeyCollection
  ) {
    self.host = host
    self.port = port
    self.database = database
    self.slackClient = slackClient
    self.slackChannelId = slackChannelId
    self.keys = keys
  }
}

// MARK: - Live

extension RudeusServerEnvironment {
  /// The server environment to use in production.
  //
  /// - Parameters:
  ///   - host: The server host.
  ///   - port: The server port.
  /// - Returns: A ``RudeusServerEnvironment``.
  public static func production(host: String, port: Int) async throws -> Self {
    let env = try await Environment.dotEnv()
    let keys = JWTKeyCollection()
    await keys.add(
      hmac: HMACKey(from: env.assume("JWT_SECRET")),
      digestAlgorithm: .sha256
    )
    return Self(
      host: host,
      port: port,
      database: try await RudeusDatabase(path: "rudeus.db"),
      slackClient: HTTPSlackClient(apiKey: env.assume("SLACK_API_TOKEN")),
      slackChannelId: env.assume("SLACK_CHANNEL_ID"),
      keys: keys
    )
  }
}

// MARK: - Debug

extension RudeusServerEnvironment {
  /// The server environment to use for development.
  //
  /// - Parameters:
  ///   - host: The server host.
  ///   - port: The server port.
  /// - Returns: A ``RudeusServerEnvironment``.
  public static func debug(host: String, port: Int) async -> Self {
    let keys = JWTKeyCollection()
    await keys.add(hmac: "debug_secret", digestAlgorithm: .sha256)
    return Self(
      host: host,
      port: port,
      database: await RudeusDatabase.inMemory(),
      slackClient: EphemeralSlackClient(),
      slackChannelId: "__DEBUG_CHANNEL_ID__",
      keys: keys
    )
  }
}
