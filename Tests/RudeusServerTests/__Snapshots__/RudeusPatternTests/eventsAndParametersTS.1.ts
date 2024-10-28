// Version: 1
//
// "Events and Parameters" by why_people

export const eventsAndParameters = hapticPattern(
  events(
    continuousEvent(0.0, 2.0, { 
      DecayTime: 0.9,
      HapticIntensity: 0.5,
      HapticSharpness: 0.67 
    }),
    transientEvent(0.1, { HapticIntensity: 0.8, HapticSharpness: 0.2 }),
    soundEffectEvent("bang.caf", 0.5, { AudioVolume: 0.5 }),
    continuousSoundEvent("dead.caf", 2.0, 2.0, {})
  ),
  parameters(
    dynamicParameter("AudioReleaseTimeControl", 0.4, 0.5),
    parameterCurve("AudioPanControl", 0.0, [
      keyFrame(1.0, 0.0)
    ]),
    parameterCurve("HapticIntensityControl", 0.0, [
      keyFrame(0.1, 0.0),
      keyFrame(0.8, 0.5),
      keyFrame(0.4, 1.2)
    ])
  )
)