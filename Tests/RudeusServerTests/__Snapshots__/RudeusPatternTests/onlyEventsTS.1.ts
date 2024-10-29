// Version: 1
//
// "Only Events" by why_people

export const onlyEvents = hapticPattern(
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
        EventWaveformLoopEnabled: false
      }
    ),
    continuousSoundEvent(
      2.0,
      2.0,
      { AudioPan: 0.8, AudioVolume: 0.3 },
      { EventWaveformUseVolumeEnvelope: false }
    )
  )
)