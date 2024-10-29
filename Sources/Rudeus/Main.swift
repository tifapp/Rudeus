import ArgumentParser
import Logging
import RudeusServer

@main
struct RudeusArguments: AsyncParsableCommand {
  @Option(name: .shortAndLong)
  var hostname: String = "127.0.0.1"

  @Option(name: .shortAndLong)
  var port: Int = 8080

  func run() async throws {
    try await rudeus(host: self.hostname, port: self.port)
  }
}
