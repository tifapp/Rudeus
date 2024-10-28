// MARK: - RudeusSlackMessage

/// A message that this server posts to slack.
public struct RudeusSlackMessage: Hashable, Sendable, Codable {
  private let blocks: [SlackBlock]

  /// Creates a slack message for sharing a new haptic pattern.
  //
  /// - Parameter pattern: A ``RudeusPattern``.
  /// - Returns: A slack message.
  public static func patternShared(_ pattern: RudeusPattern) -> Self {
    Self(
      blocks: [
        .header("A new haptic pattern was shared!"),
        .section("*\(pattern.username)* has shared a new haptic pattern named *\(pattern.name)*"),
        .section("```\n\(pattern.tiFTypescript())```")
      ]
    )
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
