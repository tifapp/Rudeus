import WPFoundation
import WPHaptics

// MARK: - RudeusPattern

/// A user uploaded haptic pattern.
public struct RudeusPattern: Hashable, Sendable, Codable {
  public let id: UUIDV7
  public var user: RudeusUser
  public var description: String
  public var name: String
  public var ahapPattern: AHAPPattern
  public var platform: Platform

  public init(
    id: UUIDV7 = UUIDV7(),
    name: String,
    description: String = "",
    user: RudeusUser,
    ahapPattern: AHAPPattern,
    platform: Platform
  ) {
    self.id = id
    self.name = name
    self.description = description
    self.user = user
    self.ahapPattern = ahapPattern
    self.platform = platform
  }
}

// MARK: - Platform

extension RudeusPattern {
  public enum Platform: String, Hashable, Sendable, Codable {
    case iOS = "ios"
    case android = "android"
  }
}

// MARK: - tiF Typescript

extension RudeusPattern {
  /// Returns the typescript DSL for creating haptic patterns on the frontend.
  public func tiFTypescript() -> String {
    let eventsTS = self.argsList(stringArgs: self.ahapPattern.eventsTiFTS())
    if self.ahapPattern.hasParameters {
      return """
        \(self.headerComment)

        export const \(self.variableName) = hapticPattern(
          events(\(eventsTS))
        )
        """
    } else {
      let parametersTS = self.argsList(stringArgs: self.ahapPattern.parametersTiFTS())
      return """
        \(self.headerComment)

        export const \(self.variableName) = hapticPattern(
          events(\(eventsTS)),
          parameters(\(parametersTS))
        )
        """
    }
  }

  private func argsList(stringArgs: String) -> String {
    "\n\(stringArgs)\n  "
  }

  private var headerComment: String {
    let description =
      self.description.isEmpty
      ? "// No Description"
      : self.description.split(separator: "\n").map { "// \($0)" }
        .joined(separator: "\n")
    return """
      // Version: \(self.ahapPattern.version)
      //
      // "\(self.name)" by \(self.user.name)
      //
      \(description)
      """
  }

  private var variableName: String {
    let name = self.name.split(separator: " ")
      .map {
        $0.lowercased().firstCharacterCapitalized
      }
      .joined()
      .replacing(/[\(\)$@\&\{\}#\*,\".;:'!?<>|\-\\]/, with: "")
    guard let first = name.first else { return "pattern" }
    return first.lowercased() + name.dropFirst()
  }
}

// MARK: - Helpers

extension AHAPPattern {
  fileprivate var hasParameters: Bool {
    let eventCount = self.elements.count { element in
      guard case .event = element else { return false }
      return true
    }
    return eventCount == self.elements.count
  }

  fileprivate func eventsTiFTS() -> String {
    self.elements
      .compactMap { element in
        guard case let .event(e) = element else { return nil }
        return e.tiFTS()
      }
      .joined(separator: ",\n")
  }

  fileprivate func parametersTiFTS() -> String {
    self.elements
      .compactMap { element in
        switch element {
        case let .dynamicParameter(p): p.tiFTS()
        case let .parameterCurve(pc): pc.tiFTS()
        case .event: nil
        }
      }
      .joined(separator: ",\n")
  }
}

extension AHAPPattern.DynamicParameter {
  fileprivate func tiFTS() -> String {
    "    dynamicParameter(\"\(self.id.rawValue)\", \(self.value), \(self.time))"
  }
}

extension AHAPPattern.ParameterCurve {
  fileprivate func tiFTS() -> String {
    "    parameterCurve(\"\(self.id.rawValue)\", \(self.time), \(self.controlPointsTiFTS()))"
  }

  fileprivate func controlPointsTiFTS() -> String {
    guard !self.controlPoints.isEmpty else { return "[]" }
    let isMultiline = self.controlPoints.count > 2
    let entries = self.controlPoints.map { "keyFrame(\($0.value), \($0.time))" }
    if isMultiline {
      return "[\n\(entries.map { "      \($0)" }.joined(separator: ",\n"))\n    ]"
    }
    return "[\(entries.joined(separator: ", "))]"
  }
}

extension AHAPPattern.Event {
  fileprivate func tiFTS() -> String {
    let space = "\n      "
    let endSpace = "\n    "
    switch self {
    case let .audioContinuous(e):
      let properties = "{ EventWaveformUseVolumeEnvelope: \(e.waveformUseVolumeEnvelope) }"
      return
        "    continuousSoundEvent(\(space)\(e.time),\(space)\(e.duration),\(space)\(e.parameters.tiFTS(newlineIndent: 8)),\(space)\(properties)\(endSpace))"
    case let .audioCustom(e):
      let propertySpace = "\n        "
      let durationProperty =
        if let d = e.duration {
          ",\(propertySpace)EventDuration: \(d)"
        } else {
          ""
        }
      let properties =
        "{\(propertySpace)EventWaveformUseVolumeEnvelope: \(e.waveformUseVolumeEnvelope),\(propertySpace)EventWaveformLoopEnabled: \(e.waveformLoopEnabled)\(durationProperty)\(space)}"
      return
        "    soundEffectEvent(\(space)\"\(e.waveformPath)\",\(space)\(e.time),\(space)\(e.parameters.tiFTS(newlineIndent: 8)),\(space)\(properties)\(endSpace))"
    case let .hapticContinuous(e):
      return
        "    continuousEvent(\(e.time), \(e.duration), \(e.parameters.tiFTS(newlineIndent: 6)))"
    case let .hapticTransient(e):
      return "    transientEvent(\(e.time), \(e.parameters.tiFTS(newlineIndent: 6)))"
    }
  }
}

extension AHAPPattern.EventParameters {
  fileprivate func tiFTS(newlineIndent: Int) -> String {
    guard !self.entries.isEmpty else { return "{}" }
    let isMultiline = self.entries.count > 2
    let objectEntries = self.entries.map { (key, value) in "\(key.rawValue): \(value)" }.sorted()
    if isMultiline {
      let entryIndent = String(repeating: " ", count: newlineIndent)
      let endBraceIndent = String(repeating: " ", count: newlineIndent - 2)
      return
        "{ \n\(objectEntries.map { "\(entryIndent)\($0)" }.joined(separator: ",\n")) \n\(endBraceIndent)}"
    }
    return "{ \(objectEntries.joined(separator: ", ")) }"
  }
}
