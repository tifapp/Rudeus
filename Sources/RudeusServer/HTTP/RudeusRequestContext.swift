import Hummingbird

// MARK: - RudeusRequestContext

/// The request context for this server.
public struct RudeusRequestContext: RequestContext {
  public var coreContext: CoreRequestContextStorage
  public var user: RudeusUser?

  public init(source: Hummingbird.ApplicationRequestContextSource) {
    self.coreContext = CoreRequestContextStorage(source: source)
  }
}

// MARK: - Require User

extension RudeusRequestContext {
  /// Returns the user if one is present in the context and throws a 401 status code otherwise.
  public func requireUser() throws -> RudeusUser {
    guard let user else { throw HTTPError(.unauthorized, message: "Unauthorized") }
    return user
  }
}
