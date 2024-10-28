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
      ahapPattern: AHAPPattern()
    )
    assertSnapshot(of: pattern.tiFTypescript(), as: .tiFTS)
  }

  @Test("Only Events Typescript")
  func onlyEventsTS() {
    let ahapPattern = AHAPPattern(
      .event(
        .hapticContinuous(
          time: 0,
          duration: 2,
          parameters: [.hapticIntensity: 0.5, .hapticSharpness: 0.67, .decayTime: 0.9]
        )
      ),
      .event(
        .hapticTransient(time: 0.1, parameters: [.hapticIntensity: 0.8, .hapticSharpness: 0.2])
      ),
      .event(
        .audioCustom(
          time: 0.5,
          waveformPath: "bang.caf",
          waveformLoopEnabled: true,
          parameters: [.audioVolume: 0.5]
        )
      ),
      .event(.audioContinuous(time: 2, duration: 2, waveformPath: "dead.caf"))
    )
    let pattern = RudeusPattern(
      name: "Only Events",
      username: "why_people",
      ahapPattern: ahapPattern
    )
    assertSnapshot(of: pattern.tiFTypescript(), as: .tiFTS)
  }

  @Test("Events and Parameters tiF Typescript")
  func eventsAndParametersTS() {
    let ahapPattern = AHAPPattern(
      .event(
        .hapticContinuous(
          time: 0,
          duration: 2,
          parameters: [.hapticIntensity: 0.5, .hapticSharpness: 0.67, .decayTime: 0.9]
        )
      ),
      .event(
        .hapticTransient(time: 0.1, parameters: [.hapticIntensity: 0.8, .hapticSharpness: 0.2])
      ),
      .dynamicParameter(id: .audioReleaseTimeControl, time: 0.5, value: 0.4),
      .event(
        .audioCustom(
          time: 0.5,
          waveformPath: "bang.caf",
          waveformLoopEnabled: true,
          parameters: [.audioVolume: 0.5]
        )
      ),
      .parameterCurve(id: .audioPanControl, time: 0, controlPoints: [.point(time: 0, value: 1)]),
      .event(.audioContinuous(time: 2, duration: 2, waveformPath: "dead.caf")),
      .parameterCurve(
        id: .hapticIntensityControl,
        time: 0,
        controlPoints: [
          .point(time: 0, value: 0.1),
          .point(time: 0.5, value: 0.8),
          .point(time: 1.2, value: 0.4)
        ]
      )
    )
    let pattern = RudeusPattern(
      name: "Events and Parameters",
      username: "why_people",
      ahapPattern: ahapPattern
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
