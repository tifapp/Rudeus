import Foundation
import JWTKit

// MARK: - RudeusUser

/// A user data type.
public struct RudeusUser: Hashable, Sendable {
  public let id: UUID
  public let name: String

  public init(id: UUID, name: String) {
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
  public static let rudeus = Self(id: UUID(), name: "Rudeus Greyrat")
  public static let whyPeople = Self(id: UUID(), name: "why_people")
  public static let matthew = Self(id: UUID(), name: "Matthew")
}
