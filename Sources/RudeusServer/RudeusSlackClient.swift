import AsyncHTTPClient
import Foundation
import Logging
import NIOHTTP1
import Synchronization

// MARK: - RudeusSlackClient

/// A protocol for slack interactions.
public protocol RudeusSlackClient {
  /// Sends a message to slack.
  ///
  /// - Parameter message: A ``RudeusSlackMessage``.
  func send(message: RudeusSlackMessage) async throws
}

// MARK: HTTPSlackClient

/// A ``RudeusSlackClient`` that uses AsyncHTTPClient with the Slack API.
public struct HTTPSlackClient {
  private let apiKey: String

  public init(apiKey: String) {
    self.apiKey = apiKey
  }
}

extension HTTPSlackClient: RudeusSlackClient {
  public func send(message: RudeusSlackMessage) async throws {
    var request = HTTPClientRequest(url: "https://slack.com/api/chat.postMessage")
    request.method = .POST
    request.headers.add(name: "Authorization", value: "Bearer \(self.apiKey)")
    request.headers.add(name: "Content-Type", value: "application/json")
    request.body = .bytes(try JSONEncoder().encode(message))
    let resp = try await HTTPClient.shared.execute(request, timeout: .minutes(1))
    if resp.status.code > 299 {
      throw SendMessageError.badResponse(status: resp.status)
    }
  }
}

extension HTTPSlackClient {
  public enum SendMessageError: Error {
    case badResponse(status: HTTPResponseStatus)
  }
}

// MARK: - EphemeralSlackClient

private let logger = Logger(label: "rudeus.ephemeral.slack.client")

/// A ``RudeusSlackClient`` that records slack messages in memory.
public final class EphemeralSlackClient {
  private let _messages = Mutex([RudeusSlackMessage]())

  public var messages: [RudeusSlackMessage] {
    self._messages.withLock { $0 }
  }

  public init() {}
}

extension EphemeralSlackClient: RudeusSlackClient {
  public func send(message: RudeusSlackMessage) async throws {
    self._messages.withLock { $0.append(message) }
    logger.debug("Slack Message Sent", metadata: ["message": .string(String(describing: message))])
  }
}
