import RudeusServer
import Testing
import WPHaptics
import WPSnapshotTesting

@Suite("RudeusSlackMessage tests")
struct RudeusSlackMessageTests {
  @Test("Slack Blocks iOS")
  func slackBlocksIOS() {
    let pattern = RudeusPattern(
      name: "Events and Parameters",
      user: .whyPeople,
      ahapPattern: .eventsAndParameters,
      platform: .iOS
    )
    assertSnapshot(
      of: RudeusSlackMessage.patternShared(channelId: "test", pattern),
      as: .json
    )
  }

  @Test("Slack Blocks Android")
  func slackBlocksAndroid() {
    let pattern = RudeusPattern(
      name: "Events and Parameters",
      description: "This is a cool pattern",
      user: .whyPeople,
      ahapPattern: .eventsAndParameters,
      platform: .android
    )
    assertSnapshot(
      of: RudeusSlackMessage.patternShared(channelId: "test", pattern),
      as: .json
    )
  }
}
