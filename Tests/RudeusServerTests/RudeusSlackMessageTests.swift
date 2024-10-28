import RudeusServer
import Testing
import WPHaptics
import WPSnapshotTesting

@Suite("RudeusSlackMessage tests")
struct RudeusSlackMessageTests {
  @Test("Slack Blocks")
  func slackBlocks() {
    let pattern = RudeusPattern(
      name: "Events and Parameters",
      username: "why_people",
      ahapPattern: .eventsAndParameters
    )
    assertSnapshot(
      of: RudeusSlackMessage.patternShared(channelId: "test", pattern),
      as: .json
    )
  }
}
