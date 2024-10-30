import ArgumentParser
import Foundation
import Logging
import RudeusServer

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
    if self.useLocalNetwork, let ipAddress = localIPAddress() {
      host = ipAddress
    }
    try await rudeus(host: host, port: self.port)
  }
}

private func localIPAddress() -> String? {
  var address: String?
  var ifaddr: UnsafeMutablePointer<ifaddrs>?

  if getifaddrs(&ifaddr) == 0 {
    var ptr = ifaddr
    while ptr != nil {
      let interface = ptr!.pointee
      let addrFamily = interface.ifa_addr.pointee.sa_family
      if addrFamily == UInt8(AF_INET) {
        let name = String(cString: interface.ifa_name)
        if name == "en0" {
          var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
          if getnameinfo(
            interface.ifa_addr,
            socklen_t(interface.ifa_addr.pointee.sa_len),
            &hostname,
            socklen_t(hostname.count),
            nil,
            socklen_t(0),
            NI_NUMERICHOST
          ) == 0 {
            address = String(cString: hostname, encoding: .utf8)
          }
        }
      }
      ptr = ptr!.pointee.ifa_next
    }
    freeifaddrs(ifaddr)
  }
  return address
}
