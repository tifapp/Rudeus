import SQLiteNIO
import WPHaptics

extension SQLiteRow {
  /// Attempts to return an `AHAPPattern` from a column.
  ///
  /// - Parameter column: The name of the column.
  /// - Returns: An optional `AHAPPattern`.
  public func ahapPattern(column: String) throws -> AHAPPattern? {
    try self.column(column)?.blob
      .flatMap { buffer in buffer.getData(at: 0, length: buffer.readableBytes) }
      .flatMap { data in try AHAPPattern(from: data) }
  }
}
