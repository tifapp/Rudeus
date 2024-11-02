import ArgumentParser
import Logging
import RudeusServer
import WPFoundation

@main
struct RudeusArguments: AsyncParsableCommand {
  @Option(name: .shortAndLong)
  var hostname: String = "127.0.0.1"

  @Option(name: .shortAndLong)
  var port: Int = 8080

  @Option(name: .shortAndLong)
  var useLocalNetwork: Bool = false

  func run() async throws {
    var host = self.hostname
    if self.useLocalNetwork, let ipAddress = IPV4Address.localPrivate {
      host = ipAddress.description
    }
    try await rudeus(host: host, port: self.port)
  }
}
