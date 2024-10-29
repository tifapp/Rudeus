import Foundation
import Hummingbird
import HummingbirdTesting
import RudeusServer
import Testing

@Suite("RudeusApplication tests")
struct RudeusApplicationTests {
  private let app: RudeusApplication

  init() async {
    self.app = await RudeusApplication(environment: .debug(host: "127.0.0.1", port: 8080))
  }

  @Test("Register Save and View Patterns")
  func normalUserFlow() async throws {
    try await self.app.test(.router) { client in
      let registerRequest = RudeusRegisterRequest(name: "Blob")
      let token = try await client.execute(
        uri: "/api/register",
        method: .post,
        body: try registerRequest.byteBuffer()
      ) { resp in
        #expect(resp.status == .created)
        let body = try JSONDecoder().decode(RudeusRegisterResponse.self, from: resp.body)
        #expect(body.name == "Blob")
        return body.token
      }

      let patternRequest = RudeusSavePatternRequest(
        name: "Test",
        ahapPattern: .eventsAndParameters,
        platform: .iOS
      )
      let pattern = try await client.execute(
        uri: "/api/pattern",
        method: .post,
        headers: [.authorization: "Bearer \(token)"],
        body: try patternRequest.byteBuffer()
      ) { resp in
        #expect(resp.status == .created)
        let body = try JSONDecoder().decode(RudeusPattern.self, from: resp.body)
        #expect(body.name == "Test")
        #expect(body.ahapPattern == .eventsAndParameters)
        #expect(body.platform == .iOS)
        return body
      }
      let expectedMessage = RudeusSlackMessage.patternShared(
        channelId: self.app.environment.slackChannelId,
        pattern
      )
      #expect(self.app.environment.ephemeralSlackClient.messages == [expectedMessage])

      try await client.execute(uri: "/api/pattern", method: .get) { resp in
        #expect(resp.status == .ok)
        let body = try JSONDecoder().decode(RudeusPatternsResponse.self, from: resp.body)
        #expect(body.patterns == [pattern])
      }
    }
  }
}

extension Encodable {
  func byteBuffer() throws -> ByteBuffer {
    try JSONEncoder().encodeAsByteBuffer(self, allocator: ByteBufferAllocator())
  }
}

extension RudeusServerEnvironment {
  var ephemeralSlackClient: EphemeralSlackClient {
    self.slackClient as! EphemeralSlackClient
  }
}
