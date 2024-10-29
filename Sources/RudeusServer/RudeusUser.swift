import JWTKit
import WPFoundation

// MARK: - RudeusUser

/// A user data type.
public struct RudeusUser: Hashable, Sendable {
  public let id: UUIDV7
  public let name: String

  public init(id: UUIDV7, name: String) {
    self.id = id
    self.name = name
  }
}

// MARK: - JWTPayload Conformance

extension RudeusUser: JWTPayload {
  public func verify(using algorithm: some JWTKit.JWTAlgorithm) async throws {
  }
}

// MARK: - Mocks

extension RudeusUser {
  public static let rudeus = Self(id: UUIDV7(), name: "Rudeus Greyrat")
  public static let whyPeople = Self(id: UUIDV7(), name: "why_people")
  public static let matthew = Self(id: UUIDV7(), name: "Matthew")
}
