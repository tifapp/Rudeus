import AsyncHTTPClient
import Foundation
import Hummingbird
import NIOHTTP1

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

  public init(environment: Environment) {
    self.apiKey = environment.assume("SLACK_API_TOKEN")
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
