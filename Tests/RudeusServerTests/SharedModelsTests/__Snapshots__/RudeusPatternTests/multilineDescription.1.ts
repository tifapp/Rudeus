// Version: 1
//
// "Events and Parameters" by why_people
//
// Hello world, I am a
// multiline description that should be commmented out on
// each line.
// And that includes whitespace too!

export const eventsAndParameters = hapticPattern(
  events(
    continuousEvent(0.0, 2.0, { 
      DecayTime: 0.9,
      HapticIntensity: 0.5,
      HapticSharpness: 0.67 
    }),
    transientEvent(0.1, { HapticIntensity: 0.8, HapticSharpness: 0.2 }),
    soundEffectEvent(
      "bang.caf",
      0.5,
      { AudioVolume: 0.5 },
      {
        EventWaveformUseVolumeEnvelope: false,
        EventWaveformLoopEnabled: false,
        EventDuration: 3.0
      }
    ),
    continuousSoundEvent(
      2.0,
      2.0,
      { 
        AudioBrightness: 0.9,
        AudioPitch: 0.6,
        AudioVolume: 0.8 
      },
      { EventWaveformUseVolumeEnvelope: true }
    )
  ),
  parameters(
    dynamicParameter("AudioReleaseTimeControl", 0.4, 0.5),
    parameterCurve("AudioPanControl", 0.0, [keyFrame(1.0, 0.0)]),
    parameterCurve("HapticIntensityControl", 0.0, [
      keyFrame(0.1, 0.0),
      keyFrame(0.8, 0.5),
      keyFrame(0.4, 1.2)
    ])
  )
)