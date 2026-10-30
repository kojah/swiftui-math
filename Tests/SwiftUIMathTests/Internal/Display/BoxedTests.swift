import CoreGraphics
import Foundation
import Testing

@testable import SwiftUIMath

struct BoxedTests {
  @Test func nestedBoxPreservesScriptsAndCopies() throws {
    let source = #"\boxed{\frac{1}{\boxed{x+1}}}_a^b"#
    let parsed = try #require(Math.Parser.build(fromString: source))
    let atom = try #require(parsed.atoms.first as? Math.Boxed)
    #expect(atom.subscript != nil)
    #expect(atom.superscript != nil)
    let copied = try #require(atom.copy() as? Math.Boxed)
    #expect(copied !== atom)
    #expect(copied.innerList !== atom.innerList)
    #expect(Math.Parser.atomListToString(parsed) == #"\boxed{\frac{1}{\boxed{x+1}}}^{b}_{a}"#)
  }

  @Test(arguments: [
    #"\boxed{E=mc^2}"#, #"\boxed{\frac{1}{2}}"#, #"\boxed{\boxed{x}}"#, #"\boxed{}"#,
  ])
  func borderEnclosesContent(_ source: String) throws {
    let font = try #require(Math.PlatformFont(font: .init(name: .latinModern, size: 20)))
    let atoms = try #require(Math.Parser.build(fromString: source))
    let display = try #require(
      Math.Typesetter.createLineForMathList(atoms, font: font, style: .display))
    let box = try #require(display.children.first as? Math.DisplayBox)
    #expect(box.width > box.inner.width)
    #expect(box.ascent > box.inner.ascent)
    #expect(box.descent > box.inner.descent)
    #expect(box.bounds.contains(box.inner.bounds))
    box.position = CGPoint(x: 31, y: 47)
    #expect(box.bounds.contains(box.inner.bounds))
    #expect(box.inner.position.y == 47)
    #expect(box.inner.position.x > 31)
  }

  @Test func malformedBoxStillFails() {
    #expect(Math.Parser.build(fromString: #"\boxed"#) == nil)
    #expect(Math.Parser.build(fromString: #"\boxed   "#) == nil)
    #expect(Math.Parser.build(fromString: #"\boxed{\frac{1}{"#) == nil)
    #expect(Math.Parser.build(fromString: #"\boxed{\notacommand{x}}"#) == nil)
  }
}
