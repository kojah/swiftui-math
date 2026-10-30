import CoreGraphics
import Foundation
import Testing

@testable import SwiftUIMath

struct NamedOperatorTests {
  private func display(_ source: String, style: Math.Style.Level = .display) throws
    -> Math.DisplayList
  {
    let font = try #require(Math.PlatformFont(font: .init(name: .latinModern, size: 20)))
    let atoms = try #require(Math.Parser.build(fromString: source))
    return try #require(Math.Typesetter.createLineForMathList(atoms, font: font, style: style))
  }

  @Test func uprightTextAndOperatorSpacingMatchBuiltIn() throws {
    let named = try display(#"a\operatorname{sin}x"#)
    let builtIn = try display(#"a\sin x"#)
    #expect(abs(named.width - builtIn.width) < 0.001)
    let run = try #require(
      named.children.compactMap { $0 as? Math.DisplayTextRun }.first { $0.text == "sin" })
    #expect(run.text == "sin")
    let single = try display(#"\operatorname{f}"#)
    #expect(single.children.first is Math.DisplayTextRun)
  }

  @Test func starredLimitsFollowDisplayStyleAndExplicitOverrides() throws {
    let source = #"\operatorname*{arg max}_{x}^y"#
    #expect(try display(source).children.first is Math.DisplayLargeOperator)
    let inline = try display(source, style: .text)
    #expect(!inline.children.contains { $0 is Math.DisplayLargeOperator })
    #expect(inline.children.contains { ($0 as? Math.DisplayTextRun)?.text == "arg max" })
    #expect(
      try display(#"\operatorname{rank}\limits_{x}"#, style: .text).children.first
        is Math.DisplayLargeOperator)
    let noLimits = try display(#"\operatorname*{rank}\nolimits_{x}"#)
    #expect(!noLimits.children.contains { $0 is Math.DisplayLargeOperator })
    #expect(noLimits.children.contains { ($0 as? Math.DisplayTextRun)?.text == "rank" })
  }

  @Test(arguments: [
    #"\operatorname{rank}_x"#, #"\operatorname*{arg max}_x^y"#, #"\operatorname{f}\limits_x"#,
    #"\operatorname*{f}\nolimits_x"#, #"\operatorname{}"#,
  ])
  func roundTripAndCopy(_ source: String) throws {
    let list = try #require(Math.Parser.build(fromString: source))
    let op = try #require(list.atoms.first as? Math.LargeOperator)
    let copy = try #require(op.copy() as? Math.LargeOperator)
    #expect(copy !== op)
    #expect(copy.isNamedOperator)
    #expect(copy.usesDisplayLimits == op.usesDisplayLimits)
    let serialized = Math.Parser.atomListToString(list)
    let reparsed = try #require(Math.Parser.build(fromString: serialized))
    #expect(Math.Parser.atomListToString(reparsed) == serialized)
    let rendered = try display(source)
    #expect(rendered.width.isFinite)
    #expect(rendered.ascent.isFinite)
  }

  @Test(arguments: [
    #"\operatorname"#, #"\operatorname rank"#, #"\operatorname{rank"#, #"\operatorname{\foo}"#,
    #"\operatorname{{rank}}"#,
  ])
  func unsupportedArgumentsFailWithoutDroppingContent(_ source: String) {
    #expect(Math.Parser.build(fromString: source) == nil)
  }
}
