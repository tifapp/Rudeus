import Hummingbird
import JWTKit

/// Middleware to handle parsing JWTs from the authorization header.
///
/// If the authorization header does not include a valid JWT, or if no authorization header is
/// provided, then this middleware falls through to the next middleware in the chain.
public struct RudeusAuthenticationMiddleware: RouterMiddleware {
  public typealias Context = RudeusRequestContext

  private let keys: JWTKeyCollection

  public init(keys: JWTKeyCollection) {
    self.keys = keys
  }

  public func handle(
    _ input: Request,
    context: Context,
    next: (Input, Context) async throws -> Response
  ) async throws -> Response {
    guard let authorization = input.headers[.authorization] else {
      return try await next(input, context)
    }
    let splits = authorization.split(separator: " ", maxSplits: 2)
    guard splits.count == 2 else {
      return try await next(input, context)
    }
    var context = context
    do {
      context.user = try await self.keys.verify(String(splits[1]), as: RudeusUser.self)
    } catch {
      return try await next(input, context)
    }
    return try await next(input, context)
  }
}
