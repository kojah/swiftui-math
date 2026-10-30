import CoreGraphics
import Foundation

extension Math {
  /// Native brace geometry keeps stroke weight fixed as the formula grows.
  final class DisplayUnderbrace: DisplayNode {
    let inner: DisplayList
    let lower: DisplayList?
    let upper: DisplayList?
    let braceWidth: CGFloat
    let braceHeight: CGFloat
    let lineThickness: CGFloat
    let gap: CGFloat

    init(
      inner: DisplayList, lower: DisplayList?, upper: DisplayList?, fontSize: CGFloat,
      lineThickness: CGFloat, position: CGPoint, range: NSRange
    ) {
      self.inner = inner
      self.lower = lower
      self.upper = upper
      self.braceWidth = max(inner.width, fontSize * 0.5)
      self.braceHeight = fontSize * 0.22
      self.lineThickness = lineThickness
      self.gap = fontSize * 0.12
      super.init()
      width = max(braceWidth + lineThickness, lower?.width ?? 0, upper?.width ?? 0)
      ascent = inner.ascent + (upper.map { gap + $0.ascent + $0.descent } ?? 0)
      descent =
        inner.descent + gap + braceHeight + lineThickness
        + (lower.map { gap + $0.ascent + $0.descent } ?? 0)
      self.range = range
      self.position = position
      updatePositions()
    }

    override var position: CGPoint {
      didSet { updatePositions() }
    }

    var braceOrigin: CGPoint {
      CGPoint(
        x: position.x + (width - braceWidth) / 2,
        y: position.y - inner.descent - gap - lineThickness / 2)
    }

    var braceBounds: CGRect {
      CGRect(
        x: braceOrigin.x - lineThickness / 2,
        y: braceOrigin.y - braceHeight - lineThickness / 2,
        width: braceWidth + lineThickness, height: braceHeight + lineThickness)
    }

    var bracePath: CGPath {
      let path = CGMutablePath()
      let curl = min(braceWidth / 4, braceHeight)
      let middle = braceWidth / 2
      let halfHeight = -braceHeight / 2
      path.move(to: .zero)
      path.addCurve(
        to: CGPoint(x: curl, y: halfHeight),
        control1: CGPoint(x: 0, y: halfHeight), control2: CGPoint(x: curl / 2, y: halfHeight))
      path.addLine(to: CGPoint(x: middle - curl, y: halfHeight))
      path.addCurve(
        to: CGPoint(x: middle, y: -braceHeight),
        control1: CGPoint(x: middle - curl / 2, y: halfHeight),
        control2: CGPoint(x: middle, y: halfHeight))
      path.addCurve(
        to: CGPoint(x: middle + curl, y: halfHeight),
        control1: CGPoint(x: middle, y: halfHeight),
        control2: CGPoint(x: middle + curl / 2, y: halfHeight))
      path.addLine(to: CGPoint(x: braceWidth - curl, y: halfHeight))
      path.addCurve(
        to: CGPoint(x: braceWidth, y: 0),
        control1: CGPoint(x: braceWidth - curl / 2, y: halfHeight),
        control2: CGPoint(x: braceWidth, y: halfHeight))
      return path
    }

    private func updatePositions() {
      inner.position = CGPoint(x: position.x + (width - inner.width) / 2, y: position.y)
      if let lower {
        lower.position = CGPoint(
          x: position.x + (width - lower.width) / 2,
          y: braceBounds.minY - gap - lower.ascent)
      }
      if let upper {
        upper.position = CGPoint(
          x: position.x + (width - upper.width) / 2,
          y: position.y + inner.ascent + gap + upper.descent)
      }
    }
  }
}
