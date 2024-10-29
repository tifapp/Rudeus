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
