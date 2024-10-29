import Hummingbird
import HummingbirdTesting
import JWTKit
import RudeusServer
import Testing

@Suite("RudeusAuthenticationMiddleware tests")
struct RudeusAuthenticationMiddlewareTests {
  private let keys = JWTKeyCollection()
  private let app: Application<RouterResponder<RudeusRequestContext>>

  init() async {
    await self.keys.add(hmac: "test_secret", digestAlgorithm: .sha256)
    let router = Router(context: RudeusRequestContext.self)
    router.add(middleware: RudeusAuthenticationMiddleware(keys: self.keys))
      .get("user") { _, context in
        try context.requireUser().name
      }
    self.app = Application(router: router)
  }

  @Test("401s when no Bearer Token Supplied")
  func noBearer() async throws {
    try await self.app.test(.router) { client in
      try await client.execute(uri: "/user", method: .get) { resp in
        #expect(resp.status == .unauthorized)
      }
    }
  }

  @Test("401s when Non-Bearer Token Supplied")
  func nonBearer() async throws {
    let jwt = try await keys.sign(RudeusUser.whyPeople)
    try await self.app.test(.router) { client in
      try await client.execute(
        uri: "/user",
        method: .get,
        headers: [.authorization: jwt]
      ) { resp in
        #expect(resp.status == .unauthorized)
      }
    }
  }

  @Test("401s when Invalid Bearer Token Supplied")
  func invalidBearer() async throws {
    try await self.app.test(.router) { client in
      try await client.execute(
        uri: "/user",
        method: .get,
        headers: [.authorization: "Bearer skjsiuhsihiuhsihiudhihiuhdiuh"]
      ) { resp in
        #expect(resp.status == .unauthorized)
      }
    }
  }

  @Test("200 when Valid Bearer Token Supplied")
  func validBearer() async throws {
    let user = RudeusUser.whyPeople
    let jwt = try await keys.sign(user)
    try await self.app.test(.router) { client in
      try await client.execute(
        uri: "/user",
        method: .get,
        headers: [.authorization: "Bearer \(jwt)"]
      ) { resp in
        #expect(resp.status == .ok)
        #expect(resp.body.getString(at: 0, length: user.name.count) == user.name)
      }
    }
  }
}
