import CoreGraphics
import CoreText
import Foundation

extension Math {
  final class DisplayTextRun: DisplayNode {
    var attributedString: NSAttributedString
    var font: Math.Font
    var atoms: [Math.Atom]
    var text: String { attributedString.string }
    private let inkRight: CGFloat
    override var renderingWidth: CGFloat { max(width, inkRight) }

    init(
      attributedString: NSAttributedString,
      font: Math.Font,
      position: CGPoint = .zero,
      range: NSRange,
      atoms: [Math.Atom]
    ) {
      let line = CTLineCreateWithAttributedString(attributedString)
      self.inkRight = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds).maxX
      self.attributedString = attributedString
      self.font = font
      self.atoms = atoms
      super.init()
      self.position = position
      self.range = range
    }
  }
}
