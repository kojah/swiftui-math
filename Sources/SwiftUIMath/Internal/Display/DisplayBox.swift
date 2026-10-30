import CoreGraphics
import Foundation

extension Math {
  final class DisplayBox: DisplayNode {
    let inner: DisplayList
    let inset: CGFloat
    let lineThickness: CGFloat

    init(
      inner: DisplayList, padding: CGFloat, lineThickness: CGFloat, position: CGPoint,
      range: NSRange
    ) {
      self.inner = inner
      self.inset = padding + lineThickness
      self.lineThickness = lineThickness
      super.init()
      self.width = inner.width + 2 * inset
      self.ascent = inner.ascent + inset
      self.descent = inner.descent + inset
      self.range = range
      self.position = position
      updateInnerPosition()
    }

    override var position: CGPoint {
      didSet { updateInnerPosition() }
    }

    private func updateInnerPosition() {
      inner.position = CGPoint(x: position.x + inset, y: position.y)
    }
  }
}
