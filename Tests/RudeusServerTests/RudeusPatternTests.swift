import RudeusServer
import Testing
import WPHaptics
import WPSnapshotTesting

@Suite("RudeusPattern tests")
struct RudeusPatternTests {
  @Test("Empty Pattern Typescript")
  func emptyTS() {
    let pattern = RudeusPattern(
      name: "Test Empty",
      username: "whypeople",
      ahapPattern: AHAPPattern(),
      platform: .iOS
    )
    assertSnapshot(of: pattern.tiFTypescript(), as: .tiFTS)
  }

  @Test("Only Events Typescript")
  func onlyEventsTS() {
    let pattern = RudeusPattern(
      name: "Only Events",
      username: "why_people",
      ahapPattern: .eventsOnly,
      platform: .iOS
    )
    assertSnapshot(of: pattern.tiFTypescript(), as: .tiFTS)
  }

  @Test("Events and Parameters tiF Typescript")
  func eventsAndParametersTS() {
    let pattern = RudeusPattern(
      name: "Events and Parameters",
      username: "why_people",
      ahapPattern: .eventsAndParameters,
      platform: .android
    )
    assertSnapshot(of: pattern.tiFTypescript(), as: .tiFTS)
  }
}

extension Snapshotting where Value == String, Format == String {
  static var tiFTS: Self {
    var snapshotting = SimplySnapshotting.lines
    snapshotting.pathExtension = "ts"
    return snapshotting
  }
}
