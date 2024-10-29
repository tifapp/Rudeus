import SQLiteNIO
import WPFoundation

extension SQLiteRow {
  /// Attempts to return a `UUIDV7` from a column.
  ///
  /// - Parameter column: The name of the column.
  /// - Returns: An optional `UUIDV7`.
  public func uuidv7(column: String) -> UUIDV7? {
    self.column(column)?.blob
      .flatMap { buffer in buffer.getUUIDBytes(at: 0).flatMap { UUIDV7($0) } }
  }
}
