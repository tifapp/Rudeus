// MARK: - RudeusSlackMessage

/// A message that this server posts to slack.
public struct RudeusSlackMessage: Hashable, Sendable, Codable {
  private let channel: String
  private let blocks: [SlackBlock]

  /// Creates a slack message for sharing a new haptic pattern.
  //
  /// - Parameters:
  ///   - chahnelId: The ID of the slack channel to send the message to.
  ///   - pattern: A ``RudeusPattern``.
  /// - Returns: A slack message.
  public static func patternShared(channelId: String, _ pattern: RudeusPattern) -> Self {
    var blocks = [SlackBlock.header("A new haptic pattern was shared!")]
    #if DEBUG
      blocks.append(.section("🛠️ _This message was sent for development purposes, please ignore._"))
    #endif
    blocks.append(contentsOf: [
      .section("*\(pattern.username)* has shared a new haptic pattern named *\(pattern.name)*"),
      .section(pattern.platform == .iOS ? "*Platform:* 📱 iOS" : "*Platform:* 🤖 Android"),
      .section("```\n\(pattern.tiFTypescript())```")
    ])
    return Self(channel: channelId, blocks: blocks)
  }
}

// MARK: - Slack Block

private struct SlackBlock: Hashable, Sendable, Codable {
  private let text: SlackText
  private let type: String

  static func header(_ text: String) -> Self {
    Self(text: .plainText(text), type: "header")
  }

  static func section(_ text: String) -> Self {
    Self(text: .markdown(text), type: "section")
  }
}

// MARK: - Slack Text

private struct SlackText: Hashable, Sendable, Codable {
  private let type: String
  private let text: String

  static func markdown(_ text: String) -> Self {
    Self(type: "mrkdwn", text: text)
  }

  static func plainText(_ text: String) -> Self {
    Self(type: "plain_text", text: text)
  }
}
