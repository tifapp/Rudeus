// Version: 1
//
// "Events' and Parameters' things to do and stuff like _______ that #&*(#&(#&(*#&*(&(&*#(*&*(&!!!!!!}{}{"" by why_people
//
// No Description

export const eventsAndParametersThingsToDoAndStuffLike_______That = hapticPattern(
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