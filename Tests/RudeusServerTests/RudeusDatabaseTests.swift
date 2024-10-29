import CustomDump
import RudeusServer
import Testing
import WPFoundation

@Suite("RudeusDatabase tests")
struct RudeusDatabaseTests {
  private let database: RudeusDatabase

  init() async {
    self.database = await RudeusDatabase.inMemory()
  }

  @Test("Create User with Name")
  func createUser() async throws {
    let user = try await self.database.createUser(named: "Blob")
    #expect(user.name == "Blob")
  }

  @Test("Deduplicates Names")
  func deduplicatesNames() async throws {
    let user = try await self.database.createUser(named: "Blob")
    let user2 = try await self.database.createUser(named: "Blob")
    let user3 = try await self.database.createUser(named: "Blob")
    #expect([user.name, user2.name, user3.name] == ["Blob", "Blob 2", "Blob 3"])
  }

  @Test("Save and Loads Patterns")
  func saveLoadPatterns() async throws {
    let user1 = try await self.database.createUser(named: "Blob")
    let user2 = try await self.database.createUser(named: "Blob Jr.")

    var pattern1 = RudeusPattern(
      name: "Blob's Pattern",
      user: user1,
      ahapPattern: .eventsAndParameters,
      platform: .iOS
    )
    let pattern2 = RudeusPattern(
      name: "Blob Jr's Pattern",
      user: user2,
      ahapPattern: .eventsOnly,
      platform: .android
    )

    try await self.database.save(pattern: pattern1)
    try await Task.sleep(for: .milliseconds(10))
    try await self.database.save(pattern: pattern2)
    try await Task.sleep(for: .milliseconds(10))

    var patterns = try await self.database.patterns()
    expectNoDifference(patterns, [pattern2, pattern1])

    pattern1.name = "Updated Pattern"
    try await self.database.save(pattern: pattern1)
    try await Task.sleep(for: .milliseconds(10))

    patterns = try await self.database.patterns()
    expectNoDifference(patterns, [pattern1, pattern2])
  }

  @Test("Throws Error when Trying to Save Pattern for Another User")
  func cannotSaveAnotherUserPattern() async throws {
    let user1 = try await self.database.createUser(named: "Blob")
    let user2 = try await self.database.createUser(named: "Blob Jr.")

    var pattern = RudeusPattern(
      name: "Blob's Pattern",
      user: user1,
      ahapPattern: .eventsAndParameters,
      platform: .iOS
    )
    try await self.database.save(pattern: pattern)
    pattern.user = user2

    await #expect(throws: RudeusDatabaseError.unauthorizedPatternSave) {
      try await self.database.save(pattern: pattern)
    }
  }
}
