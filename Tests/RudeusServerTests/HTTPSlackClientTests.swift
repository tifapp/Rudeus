import AsyncHTTPClient
import Hummingbird
import RudeusServer
import Testing
import WPHaptics
import WPSnapshotTesting

@Suite("HTTPClientSlackClient tests")
struct HTTPClientSlackClientTests {
  @Test("Posts Slack Message Without Throwing")
  func postsMessage() async throws {
    let env = try await Environment.dotEnv()
    let apiKey = env.assume("SLACK_API_TOKEN")
    let client = HTTPSlackClient(apiKey: apiKey)
    await #expect(throws: Never.self) {
      let pattern = RudeusPattern(
        name: "Test",
        user: .matthew,
        ahapPattern: .eventsAndParameters,
        platform: .iOS
      )
      try await client.send(
        message: .patternShared(channelId: env.assume("SLACK_CHANNEL_ID"), pattern)
      )
    }
  }
}
