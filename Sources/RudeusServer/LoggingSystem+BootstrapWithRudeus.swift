import Logging

extension LoggingSystem {
  /// Bootstraps logging for this server.
  static func bootstrapWithRudeus() {
    Self.bootstrap { label in
      StreamLogHandler.standardOutput(label: label)
    }
  }
}
