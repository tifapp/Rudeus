import WPFoundation
import WPHaptics

// MARK: - RudeusRegisterRequest

public struct RudeusRegisterRequest: Hashable, Sendable, Codable {
  public let name: String

  public init(name: String) {
    self.name = name
  }
}

// MARK: - RudeusSavePatternRequest

public struct RudeusSavePatternRequest: Hashable, Sendable, Codable {
  public let id: UUIDV7?
  public let name: String
  public let description: String
  public let ahapPattern: AHAPPattern
  public let platform: RudeusPattern.Platform

  public init(
    id: UUIDV7? = nil,
    name: String,
    description: String,
    ahapPattern: AHAPPattern,
    platform: RudeusPattern.Platform
  ) {
    self.id = id
    self.name = name
    self.description = description
    self.ahapPattern = ahapPattern
    self.platform = platform
  }
}
