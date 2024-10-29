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
    LoggingSystem.bootstrapWithRudeus()
    #if DEBUG
      let env = try await RudeusServerEnvironment.debug(host: self.hostname, port: self.port)
    #else
      let env = try await RudeusServerEnvironment.production(host: self.hostname, port: self.port)
    #endif
    try await rudeus(environment: env)
  }
}
