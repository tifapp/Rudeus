import Hummingbird
import WPFoundation

// MARK: - RudeusRegisterResponse

public struct RudeusRegisterResponse: Hashable, Sendable, ResponseCodable {
  public let id: UUIDV7
  public let name: String
  public let token: String

  public init(id: UUIDV7, name: String, token: String) {
    self.id = id
    self.name = name
    self.token = token
  }
}

// MARK: - RudeusPatternsResponse

public struct RudeusPatternsResponse: Hashable, Sendable, ResponseCodable {
  public let patterns: [RudeusPattern]

  public init(patterns: [RudeusPattern]) {
    self.patterns = patterns
  }
}

// MARK: - RudeusPattern

extension RudeusPattern: ResponseCodable {}
