import SQLiteNIO
import WPFoundation
import WPHaptics

// MARK: - RudeusDatabase

/// The database for the application.
public final actor RudeusDatabase {
  private let sqlite: SQLiteConnection

  public init(path: String) async throws {
    try await self.init(storage: .file(path: path))
  }

  private init(storage: SQLiteConnection.Storage) async throws {
    self.sqlite = try await SQLiteConnection.open(storage: storage)
    try await self.migrateV1()
  }

  deinit { Task { [sqlite] in try await sqlite.close() } }
}

// MARK: - In Memory

extension RudeusDatabase {
  public static func inMemory() async -> Self {
    try! await Self(storage: .memory)
  }
}

// MARK: - Create User

extension RudeusDatabase {
  /// Creates a new user in the database.
  ///
  /// If the name already exists, then a unique name is generated from the base name.
  ///
  /// - Parameter name: The name of the user to create.
  /// - Returns: A ``RudeusUser``.
  public func createUser(named name: String) async throws -> RudeusUser {
    let id = UUIDV7()
    let names = Set(
      try await self.sqlite.query("SELECT name FROM Users")
        .compactMap { $0.column("name")?.string }
    )
    var index = 2
    var currentName = name
    while names.contains(currentName) {
      currentName = "\(name) \(index)"
      index += 1
    }
    _ = try await self.sqlite.query(
      "INSERT INTO Users (id, name) VALUES (?, ?)",
      [.uuid(id), .text(currentName)]
    )
    return RudeusUser(id: id, name: currentName)
  }
}

// MARK: - Save Pattern

extension RudeusDatabase {
  /// Saves the specified ``RudeusPattern`` in the database.
  ///
  /// - Parameter pattern: A ``RudeusPattern``.
  @discardableResult
  public func save(pattern: RudeusPattern) async throws -> RudeusPattern {
    let rows = try await self.sqlite.query(
      """
      SELECT u.id as userId
      FROM Patterns p
      LEFT JOIN Users u
        ON u.id = p.userId
      WHERE p.id = ?
      """,
      [.uuid(pattern.id)]
    )
    let userId = rows.compactMap { $0.uuidv7(column: "userId") }.first
    let patternExists = userId != nil
    guard !patternExists || userId == pattern.user.id else {
      throw RudeusDatabaseError.unauthorizedPatternSave
    }
    var newPattern = pattern
    if patternExists {
      newPattern.ahapPattern.version += 1
    }
    _ = try await self.sqlite.query(
      """
      INSERT INTO Patterns (id, userId, name, description, ahapData, platform)
      VALUES (?, ?, ?, ?, ?, ?)
      ON CONFLICT (id) DO UPDATE
        SET
            name = ?,
            ahapData = ?,
            description = ?,
            platform = ?,
            lastUpdatedAt = unixepoch('now', 'subsec')
      """,
      [
        .uuid(newPattern.id), .uuid(newPattern.user.id), .text(newPattern.name),
        .text(newPattern.description),
        .blob(ByteBuffer(data: newPattern.ahapPattern.data())),
        .text(newPattern.platform.rawValue),
        .text(newPattern.name),
        .blob(ByteBuffer(data: newPattern.ahapPattern.data())),
        .text(newPattern.description),
        .text(newPattern.platform.rawValue)
      ]
    )
    return newPattern
  }
}

// MARK: - Pattern Exists

extension RudeusDatabase {
  /// Checks if a pattern with the specified `id` exists.
  ///
  /// - Parameter id: The id of the pattern to check.
  /// - Returns: True if the pattern with the specified `id` exists.
  public func patternExists(with id: UUIDV7) async throws -> Bool {
    let rows = try await self.sqlite.query(
      "SELECT TRUE FROM Patterns WHERE id = ?",
      [.uuid(id)]
    )
    return !rows.isEmpty
  }
}

// MARK: - Patterns

extension RudeusDatabase {
  /// Returns all the patterns stored in this database in last-save order.
  public func patterns() async throws -> [RudeusPattern] {
    let rows = try await self.sqlite.query(
      """
      SELECT p.*, u.name AS username
      FROM Patterns p
      LEFT JOIN Users u
        ON u.id = p.userId
      ORDER BY lastUpdatedAt DESC
      """
    )
    return try rows.map { row in
      let ahapBuffer = row.column("ahapData")!.blob!
      return RudeusPattern(
        id: row.uuidv7(column: "id")!,
        name: row.column("name")!.string!,
        description: row.column("description")!.string!,
        user: RudeusUser(
          id: row.uuidv7(column: "userId")!,
          name: row.column("username")!.string!
        ),
        ahapPattern: try AHAPPattern(
          from: ahapBuffer.getData(at: 0, length: ahapBuffer.readableBytes)!
        ),
        platform: (row.column("platform")?.string.flatMap(RudeusPattern.Platform.init(rawValue:)))!
      )
    }
  }
}

// MAKR: - Error

public enum RudeusDatabaseError: Hashable, Sendable, Error {
  case unauthorizedPatternSave
}

// MARK: - Migrations

extension RudeusDatabase {
  private func migrateV1() async throws {
    _ = try await self.sqlite.query(
      """
      CREATE TABLE IF NOT EXISTS Users (
        id BLOB NOT NULL PRIMARY KEY,
        name TEXT NOT NULL UNIQUE
      )
      """
    )
    _ = try await self.sqlite.query(
      """
      CREATE TABLE IF NOT EXISTS Patterns (
        id BLOB NOT NULL PRIMARY KEY,
        userId BLOB NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        ahapData BLOB NOT NULL,
        platform TEXT NOT NULL CHECK (platform IN ('ios', 'android')),
        lastUpdatedAt DATETIME NOT NULL DEFAULT (unixepoch('now', 'subsec')),
        FOREIGN KEY(userId) REFERENCES Users(id) ON DELETE CASCADE
      )
      """
    )
  }
}
