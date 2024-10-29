import WPHaptics

extension AHAPPattern {
  static let eventsOnly = AHAPPattern(
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
    .event(.audioContinuous(time: 2, duration: 2, parameters: [.audioPan: 0.8, .audioVolume: 0.3]))
  )

  static let eventsAndParameters = Self(
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
        duration: 3.0,
        parameters: [.audioVolume: 0.5]
      )
    ),
    .parameterCurve(id: .audioPanControl, time: 0, controlPoints: [.point(time: 0, value: 1)]),
    .event(
      .audioContinuous(
        time: 2,
        duration: 2,
        waveformUseVolumeEnvelope: true,
        parameters: [.audioBrightness: 0.9, .audioVolume: 0.8, .audioPitch: 0.6]
      )
    ),
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
}
