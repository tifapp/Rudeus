import SQLiteNIO
import WPFoundation

extension SQLiteData {
  /// A UUID represented by a BLOB.
  //
  /// - Parameter uuid: A `UUIDV7`.
  /// - Returns: `SQLiteData`
  public static func uuid(_ uuid: UUIDV7) -> Self {
    .blob(withUnsafeBytes(of: uuid) { ByteBuffer(data: Data($0)) })
  }
}
