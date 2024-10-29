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
      user: .whyPeople,
      ahapPattern: AHAPPattern(),
      platform: .iOS
    )
    assertSnapshot(of: pattern.tiFTypescript(), as: .tiFTS)
  }

  @Test("Weird Name Typescript")
  func weirdNameTS() {
    let pattern = RudeusPattern(
      name:
        "Events' and Parameters' things to do and stuff like _______ that #&*(#&(#&(*#&*(&(&*#(*&*(&!!!!!!}{}{\"",
      user: .whyPeople,
      ahapPattern: .eventsAndParameters,
      platform: .android
    )
    assertSnapshot(of: pattern.tiFTypescript(), as: .tiFTS)
  }

  @Test("Only Events Typescript")
  func onlyEventsTS() {
    let pattern = RudeusPattern(
      name: "Only Events",
      user: .whyPeople,
      ahapPattern: .eventsOnly,
      platform: .iOS
    )
    assertSnapshot(of: pattern.tiFTypescript(), as: .tiFTS)
  }

  @Test("Events and Parameters tiF Typescript")
  func eventsAndParametersTS() {
    let pattern = RudeusPattern(
      name: "Events and Parameters",
      user: .whyPeople,
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
