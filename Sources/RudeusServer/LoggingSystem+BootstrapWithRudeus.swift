import Logging

extension LoggingSystem {
  /// Bootstraps logging for this server.
  public static func bootstrapWithRudeus() {
    Self.bootstrap { label in
      StreamLogHandler.standardOutput(label: label)
    }
  }
}
