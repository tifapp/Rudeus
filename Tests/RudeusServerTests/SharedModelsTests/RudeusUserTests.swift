import JWTKit
import RudeusServer
import Testing
import WPFoundation

@Suite("RudeusUser tests")
struct RudeusUserTests {
  @Test("To and From JWT")
  func jwt() async throws {
    let keys = JWTKeyCollection()
    await keys.add(hmac: "secret", digestAlgorithm: .sha256)
    let user = RudeusUser(id: UUIDV7(), name: "blob")
    let jwt = try await keys.sign(user)
    let decodedUser = try await keys.verify(jwt, as: RudeusUser.self)
    #expect(user == decodedUser)
  }
}
