import CoreGraphics
import Foundation
import Testing

@testable import SwiftUIMath

struct UnderbraceTests {
  private func brace(_ source: String) throws -> Math.DisplayUnderbrace {
    let font = try #require(Math.PlatformFont(font: .init(name: .latinModern, size: 20)))
    let atoms = try #require(Math.Parser.build(fromString: source))
    let display = try #require(
      Math.Typesetter.createLineForMathList(atoms, font: font, style: .display))
    return try #require(display.children.first as? Math.DisplayUnderbrace)
  }

  @Test(arguments: [
    #"\underbrace{x+y}_{z}"#, #"\underbrace{\frac{1}{2}}_{\text{a long label}}^n"#,
    #"\underbrace{\underbrace{x}_a+y}_b"#, #"\underbrace{}"#,
  ])
  func containsFormulaBraceAndLabelsAfterRelocation(_ source: String) throws {
    let display = try brace(source)
    display.position = CGPoint(x: 31, y: 47)
    let bounds = display.bounds.insetBy(dx: -0.001, dy: -0.001)
    #expect(bounds.contains(display.inner.bounds))
    #expect(bounds.contains(display.braceBounds))
    #expect(display.braceBounds.maxY < display.inner.bounds.minY)
    if let lower = display.lower {
      #expect(bounds.contains(lower.bounds))
      #expect(lower.bounds.maxY < display.braceBounds.minY)
      #expect(abs(lower.bounds.midX - display.bounds.midX) < 0.001)
    }
    if let upper = display.upper {
      #expect(bounds.contains(upper.bounds))
      #expect(upper.bounds.minY > display.inner.bounds.maxY)
    }
  }

  @Test func longFormulaSpansWithoutThickeningStroke() throws {
    let short = try brace(#"\underbrace{x}_a"#)
    let long = try brace(#"\underbrace{x_1+x_2+x_3+x_4+x_5+x_6}_n"#)
    #expect(long.braceWidth > short.braceWidth * 5)
    #expect(long.lineThickness == short.lineThickness)
    #expect(long.braceHeight == short.braceHeight)
    #expect(long.braceWidth == long.inner.width)
    #expect(abs(long.bracePath.boundingBoxOfPath.width - long.inner.width) < 0.001)
  }

  @Test func deepCopyAndRoundTripPreserveNestedFormulaAndLabels() throws {
    let list = try #require(Math.Parser.build(fromString: #"\underbrace{\boxed{x+y}}_n^m"#))
    let atom = try #require(list.atoms.first as? Math.Underbrace)
    let copy = try #require(atom.copy() as? Math.Underbrace)
    #expect(copy !== atom)
    #expect(copy.innerList !== atom.innerList)
    #expect(copy.subscript !== atom.subscript)
    let source = Math.Parser.atomListToString(list)
    let reparsed = try #require(Math.Parser.build(fromString: source))
    #expect(Math.Parser.atomListToString(reparsed) == source)
  }

  @Test(arguments: [
    #"\underbrace"#, #"\underbrace   "#, #"\underbrace{x"#, #"\underbrace{\unknown{x}}"#,
  ])
  func malformedContentStillFails(_ source: String) {
    #expect(Math.Parser.build(fromString: source) == nil)
  }
}
