import CustomDump
import Hummingbird
import HummingbirdTesting
import RudeusServer
import Testing
import WPFoundation
import WPHaptics

@Suite("RudeusApplication tests")
struct RudeusApplicationTests {
  private let app: RudeusApplication

  private var slackClient: EphemeralSlackClient {
    self.app.environment.slackClient as! EphemeralSlackClient
  }

  init() async {
    self.app = await RudeusApplication(environment: .debug(host: "127.0.0.1", port: 8080))
  }

  @Test("Register Save and View Patterns")
  func normalUserFlow() async throws {
    try await self.app.test(.router) { client in
      let token = try await self.register(name: "Blob", client: client)

      let patternRequest = RudeusSavePatternRequest(
        name: "Test",
        description: "I am a fun pattern",
        ahapPattern: .eventsAndParameters,
        platform: .iOS
      )
      let pattern = try await self.savePattern(
        request: patternRequest,
        token: token,
        expectedStatus: .created,
        client: client
      )

      let patterns = try await self.patterns(client: client)
      #expect(patterns == [pattern])
    }
  }

  @Test("Edit Pattern Returns 200 Status Code Instead of 201")
  func editPattern() async throws {
    try await self.app.test(.router) { client in
      let token = try await self.register(name: "Blob", client: client)

      var patternRequest = RudeusSavePatternRequest(
        name: "Test",
        description: "I am a fun pattern",
        ahapPattern: .eventsAndParameters,
        platform: .iOS
      )
      var pattern = try await self.savePattern(
        request: patternRequest,
        token: token,
        expectedStatus: .created,
        client: client
      )

      patternRequest = RudeusSavePatternRequest(
        id: pattern.id,
        name: "Modified Pattern",
        description: "I am a fun agian",
        ahapPattern: .eventsAndParameters,
        platform: .iOS
      )
      pattern = try await self.savePattern(
        request: patternRequest,
        token: token,
        expectedStatus: .ok,
        client: client
      )

      let patterns = try await self.patterns(client: client)
      expectNoDifference(patterns, [pattern])
      #expect(pattern.version == 2)
    }
  }

  @Test("403s When Attempting to Edit Pattern Owned by Another User")
  func forbiddenEditPattern() async throws {
    try await self.app.test(.router) { client in
      let token = try await self.register(name: "Blob", client: client)
      let token2 = try await self.register(name: "Bitchell Dickle", client: client)

      var patternRequest = RudeusSavePatternRequest(
        name: "Test",
        description: "I am a fun pattern",
        ahapPattern: .eventsAndParameters,
        platform: .android
      )
      let pattern = try await self.savePattern(
        request: patternRequest,
        token: token,
        expectedStatus: .created,
        client: client
      )

      patternRequest = RudeusSavePatternRequest(
        id: pattern.id,
        name: "Modified Pattern",
        description: "I am a fun pattern possibly",
        ahapPattern: .eventsOnly,
        platform: .android
      )
      await #expect(throws: Error.self) {
        _ = try await self.savePattern(
          request: patternRequest,
          token: token2,
          expectedStatus: .forbidden,
          client: client
        )
      }

      let patterns = try await self.patterns(client: client)
      #expect(patterns == [pattern])
    }
  }

  @Test("Save Pattern with Invalid Token Returns 401")
  func invalidTokenPatternSave() async throws {
    try await self.app.test(.router) { client in
      let patternRequest = RudeusSavePatternRequest(
        name: "Test",
        description: "I am a fun pattern",
        ahapPattern: .eventsAndParameters,
        platform: .android
      )
      await #expect(throws: Error.self) {
        _ = try await self.savePattern(
          request: patternRequest,
          token: "klsdhjkjshkkjdhsjkdhjk",
          expectedStatus: .unauthorized,
          client: client
        )
      }
      let patterns = try await self.patterns(client: client)
      #expect(patterns == [])
    }
  }

  @Test("Attempt to Edit Non-Existent Pattern Returns 404")
  func editNonExistingPattern() async throws {
    try await self.app.test(.router) { client in
      let token = try await self.register(name: "Blob", client: client)
      let patternRequest = RudeusSavePatternRequest(
        id: UUIDV7(),
        name: "Test",
        description: "I am a fun pattern",
        ahapPattern: .eventsAndParameters,
        platform: .android
      )
      await #expect(throws: Error.self) {
        _ = try await self.savePattern(
          request: patternRequest,
          token: token,
          expectedStatus: .notFound,
          client: client
        )
      }
      let patterns = try await self.patterns(client: client)
      #expect(patterns == [])
    }
  }

  private func register(name: String, client: any TestClientProtocol) async throws -> String {
    let registerRequest = RudeusRegisterRequest(name: name)
    return try await client.execute(
      uri: "/api/register",
      method: .post,
      body: try registerRequest.byteBuffer()
    ) { resp in
      #expect(resp.status == .created)
      let body = try JSONDecoder().decode(RudeusRegisterResponse.self, from: resp.body)
      #expect(body.name == name)
      return body.token
    }
  }

  private func savePattern(
    request: RudeusSavePatternRequest,
    token: String,
    expectedStatus: HTTPResponse.Status,
    client: any TestClientProtocol
  ) async throws -> RudeusPattern {
    let pattern = try await client.execute(
      uri: "/api/pattern",
      method: .post,
      headers: [.authorization: "Bearer \(token)"],
      body: try request.byteBuffer()
    ) { resp in
      #expect(resp.status == expectedStatus)
      let body = try JSONDecoder().decode(RudeusPattern.self, from: resp.body)
      if let id = request.id {
        #expect(body.id == id)
      }
      #expect(body.name == request.name)
      #expect(body.ahapPattern == request.ahapPattern)
      #expect(body.description == request.description)
      #expect(body.platform == request.platform)
      return body
    }
    let expectedMessage = RudeusSlackMessage.patternShared(
      channelId: self.app.environment.slackChannelId,
      pattern
    )
    #expect(self.slackClient.messages.contains(expectedMessage))
    return pattern
  }

  private func patterns(client: any TestClientProtocol) async throws -> [RudeusPattern] {
    try await client.execute(uri: "/api/pattern", method: .get) { resp in
      #expect(resp.status == .ok)
      return try JSONDecoder().decode(RudeusPatternsResponse.self, from: resp.body).patterns
    }
  }
}

extension Encodable {
  func byteBuffer() throws -> ByteBuffer {
    try JSONEncoder().encodeAsByteBuffer(self, allocator: ByteBufferAllocator())
  }
}
