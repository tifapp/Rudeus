import WPFoundation
import WPHaptics

// MARK: - RudeusPattern

/// A user uploaded haptic pattern.
public struct RudeusPattern: Hashable, Sendable, Codable {
  public let id: UUID
  public let name: String
  public let username: String
  public let ahapPattern: AHAPPattern

  public init(id: UUID = UUID(), name: String, username: String, ahapPattern: AHAPPattern) {
    self.id = id
    self.name = name
    self.username = username
    self.ahapPattern = ahapPattern
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
    """
    // Version: \(self.ahapPattern.version)
    //
    // "\(self.name)" by \(self.username)
    """
  }

  private var variableName: String {
    let name = self.name.split(separator: " ").map { $0.lowercased().firstCharacterCapitalized }
      .joined()
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
    let entries = self.controlPoints.map { point in
      "      keyFrame(\(point.value), \(point.time))"
    }
    return "[\n\(entries.joined(separator: ",\n"))\n    ]"
  }
}

extension AHAPPattern.Event {
  fileprivate func tiFTS() -> String {
    switch self {
    case let .audioContinuous(e):
      return
        "    continuousSoundEvent(\"\(e.waveformPath)\", \(e.time), \(e.duration), \(e.parameters.tiFTS()))"
    case let .audioCustom(e):
      return "    soundEffectEvent(\"\(e.waveformPath)\", \(e.time), \(e.parameters.tiFTS()))"
    case let .hapticContinuous(e):
      return "    continuousEvent(\(e.time), \(e.duration), \(e.parameters.tiFTS()))"
    case let .hapticTransient(e):
      return "    transientEvent(\(e.time), \(e.parameters.tiFTS()))"
    }
  }
}

extension _AHAPEventParameters {
  fileprivate func tiFTS() -> String {
    guard !self.entries.isEmpty else { return "{}" }
    let isMultiline = self.entries.count > 2
    let objectEntries = self.entries.map { (key, value) in "\(key.rawValue): \(value)" }.sorted()
    if isMultiline {
      return "{ \n\(objectEntries.map { "      \($0)" }.joined(separator: ",\n")) \n    }"
    } else {
      return "{ \(objectEntries.joined(separator: ", ")) }"
    }
  }
}
