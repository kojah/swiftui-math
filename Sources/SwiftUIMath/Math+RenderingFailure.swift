extension Math {
  /// Source-free failure categories for clients that preserve unrenderable LaTeX.
  /// Parser messages may contain expression text and are deliberately not exposed here.
  @_spi(Textual)
  public enum RenderingFailure: String, Error, Sendable {
    case mismatchedBraces
    case invalidCommand
    case characterNotFound
    case missingDelimiter
    case invalidDelimiter
    case missingRight
    case missingLeft
    case invalidEnvironment
    case missingEnvironment
    case missingBegin
    case missingEnd
    case invalidNumberOfColumns
    case internalError
    case invalidLimits
    case malformedExpression
    case typesettingFailed
    case emptyLayout
    case invalidProposedWidth

    init(_ error: ParserError?) {
      guard let error else {
        self = .malformedExpression
        return
      }
      switch error.code {
      case .mismatchedBraces: self = .mismatchedBraces
      case .invalidCommand: self = .invalidCommand
      case .characterNotFound: self = .characterNotFound
      case .missingDelimiter: self = .missingDelimiter
      case .invalidDelimiter: self = .invalidDelimiter
      case .missingRight: self = .missingRight
      case .missingLeft: self = .missingLeft
      case .invalidEnvironment: self = .invalidEnvironment
      case .missingEnvironment: self = .missingEnvironment
      case .missingBegin: self = .missingBegin
      case .missingEnd: self = .missingEnd
      case .invalidNumberOfColumns: self = .invalidNumberOfColumns
      case .internalError: self = .internalError
      case .invalidLimits: self = .invalidLimits
      }
    }
  }
}
