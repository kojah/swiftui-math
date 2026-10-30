import SwiftUI
import Testing

@_spi(Textual) @testable import SwiftUIMath

struct RenderingFailureTests {
  private let font = Math.Font(name: .latinModern, size: 20)

  @Test func failuresDistinguishUnsupportedMalformedAndEmptyExpressions() {
    let cases: [(String, Math.RenderingFailure)] = [
      (#"\privatecommand{secret}"#, .invalidCommand),
      (#"\frac{1}{"#, .mismatchedBraces),
      ("", .emptyLayout),
      (#"\underbrace{\privatecommand{secret}}"#, .invalidCommand),
    ]
    for (source, expected) in cases {
      let result = Math.measurement(for: source, fitting: .unspecified, font: font, style: .display)
      guard case .failure(let failure) = result else {
        Issue.record("Expected a rendering failure")
        continue
      }
      #expect(failure == expected)
      #expect(!String(describing: failure).contains("secret"))
      #expect(!failure.rawValue.contains("privatecommand"))
    }
  }

  @Test func visibleMeasurementsMatchCompatibilityAPIOnCacheHitAndMiss() throws {
    for source in [#"\boxed{E=mc^2}"#, #"\underbrace{x+y}_z"#, #"\operatorname{rank}(A)"#] {
      for style in [Math.TypesettingStyle.display, .text] {
        for _ in 0..<2 {
          let measured = try Math.measurement(
            for: source, fitting: .unspecified, font: font, style: style
          ).get()
          let legacy = Math.typographicBounds(
            for: source, fitting: .unspecified, font: font, style: style)
          #expect(measured.width == legacy.width)
          #expect(measured.ascent == legacy.ascent)
          #expect(measured.descent == legacy.descent)
          #expect(measured.origin == legacy.origin)
        }
      }
    }
  }

  @Test func widthConstraintIsNotMisreportedAsInvalidSource() {
    for width: CGFloat in [0, -1] {
      let result = Math.measurement(
        for: "x", fitting: .init(width: width, height: nil), font: font, style: .display)
      guard case .failure(.invalidProposedWidth) = result else {
        Issue.record("Expected invalid width diagnostic")
        continue
      }
      #expect(
        Math.typographicBounds(
          for: "x", fitting: .init(width: width, height: nil), font: font, style: .display
        ).size == .zero)
    }
  }
}
