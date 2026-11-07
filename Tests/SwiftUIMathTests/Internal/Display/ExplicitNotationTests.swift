import Foundation
import Testing

@testable import SwiftUIMath

struct ExplicitNotationTests {
  @Test(arguments: [
    #"\mathrm{P} \;\stackrel{?}{=}\; \mathrm{NP}"#,
    #"\mathrm{NP} = \mathrm{PCP} \big(O(\log n) \; O(1)\big)"#,
    #"\mathrm{DTIME}(n) \subsetneq \mathrm{DTIME}(n^{2})"#,
  ])
  func flaggedExpressionsRender(_ source: String) throws {
    let atoms = try #require(Math.Parser.build(fromString: source))
    let font = try #require(Math.PlatformFont(font: .init(name: .latinModern, size: 20)))
    for style in [Math.Style.Level.display, .text] {
      let display = try #require(
        Math.Typesetter.createLineForMathList(atoms, font: font, style: style))
      #expect(display.width > 0)
      #expect(display.ascent > 0)
      #expect(display.width.isFinite)
    }
    #expect(Math.Parser.build(fromString: Math.Parser.atomListToString(atoms)) != nil)
  }

  @Test func stackRelationCentersAnnotationAndPreservesCopy() throws {
    let atoms = try #require(Math.Parser.build(fromString: #"\stackrel{?}{=}"#))
    let stack = try #require(atoms.atoms.first as? Math.StackRelation)
    #expect(stack.type == .relation)
    let copy = try #require(stack.copy() as? Math.StackRelation)
    #expect(copy.base !== stack.base)
    #expect(copy.annotation !== stack.annotation)
    let font = try #require(Math.PlatformFont(font: .init(name: .latinModern, size: 20)))
    let display = try #require(
      Math.Typesetter.createLineForMathList(atoms, font: font, style: .display))
    let relation = try #require(display.children.first as? Math.DisplayLargeOperator)
    let base = try #require(relation.nucleus)
    let annotation = try #require(relation.upperLimit)
    #expect(abs(base.bounds.midX - annotation.bounds.midX) < 0.001)
    #expect(annotation.position.y - annotation.descent > base.position.y + base.ascent)
    #expect(annotation.ascent + annotation.descent < font.font.size)
    #expect(Math.Parser.atomListToString(atoms) == #"\stackrel{?}{=}"#)
  }

  @Test func explicitDelimitersGrowAndKeepSpacing() throws {
    let font = try #require(Math.PlatformFont(font: .init(name: .latinModern, size: 20)))
    var previousHeight = 0.0
    for command in ["big", "Big", "bigg", "Bigg"] {
      let atoms = try #require(Math.Parser.build(fromString: "\\\(command)("))
      let delimiter = try #require(atoms.atoms.first as? Math.SizedDelimiter)
      #expect(delimiter.type == .ordinary)
      #expect((delimiter.copy() as? Math.SizedDelimiter)?.command == command)
      let display = try #require(
        Math.Typesetter.createLineForMathList(atoms, font: font, style: .display))
      let height = display.ascent + display.descent
      #expect(height > previousHeight)
      previousHeight = height
    }
    for (command, type) in [("bigl", Math.AtomType.open), ("bigr", .close), ("bigm", .relation)] {
      let atoms = try #require(Math.Parser.build(fromString: "\\\(command)|"))
      #expect(atoms.atoms.first?.type == type)
    }
    let adjacent = try #require(Math.Parser.build(fromString: #"x\big(y\big)z"#))
    #expect(
      Math.Typesetter.preprocessMathList(adjacent.finalized).filter { $0 is Math.SizedDelimiter }
        .count == 2)
  }

  @Test func strictSubsetSymbolsRemainRelations() throws {
    let atoms = try #require(Math.Parser.build(fromString: #"\subsetneq\supsetneq"#))
    #expect(atoms.atoms.map(\.nucleus) == ["⊊", "⊋"])
    #expect(atoms.atoms.allSatisfy { $0.type == .relation })
  }

  @Test(arguments: [
    #"\stackrel"#, #"\stackrel{?}"#, #"\stackrel{?}{\unknown}"#, #"\big"#, #"\big x"#,
    #"\Biggl\unknown"#,
  ])
  func malformedNotationFails(_ source: String) {
    #expect(Math.Parser.build(fromString: source) == nil)
  }
}
