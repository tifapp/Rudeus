import Hummingbird

extension Environment {
  /// Returns the environment variable value for `s` assuming it is in the environment.
  ///
  /// This method will crash the application if s is not in the environment.
  ///
  /// - Parameter s: The environment variable name.
  /// - Returns: The environment value for `s`.
  public func assume(_ s: StaticString) -> String {
    guard let value = self.get(String(describing: s)) else {
      fatalError("\(s) not present in the environment.")
    }
    return value
  }
}
