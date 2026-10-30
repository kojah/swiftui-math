import Foundation

extension Math {
  final class DisplayProvider: Sendable {
    private struct Cache {
      struct Key: Hashable {
        let latex: String
        let font: Font
        let style: TypesettingStyle
        let proposedWidth: CGFloat
      }

      let atomList = NSCache<NSString, AtomList>()
      let displayNode = NSCache<KeyBox<Key>, DisplayNode>()
    }

    static let shared = DisplayProvider()

    private let cache = ReadWriteLockIsolated<Cache>(Cache())

    func sizeThatFits(
      proposedWidth width: CGFloat,
      latex: String,
      font: Font,
      style: TypesettingStyle
    ) -> CGSize {
      display(
        for: latex,
        font: font,
        style: style,
        proposedWidth: width
      )?.bounds.size ?? .zero
    }

    func display(
      for latex: String,
      font: Font,
      style: TypesettingStyle,
      proposedWidth: CGFloat
    ) -> DisplayNode? {
      try? displayResult(for: latex, font: font, style: style, proposedWidth: proposedWidth).get()
    }

    func displayResult(
      for latex: String,
      font: Font,
      style: TypesettingStyle,
      proposedWidth: CGFloat
    ) -> Result<DisplayNode, RenderingFailure> {
      cache.withValue { cache in
        let roundedWidth = proposedWidth.halfPointRounded()
        let key = KeyBox(
          Cache.Key(
            latex: latex,
            font: font,
            style: style,
            proposedWidth: roundedWidth
          )
        )

        if let displayNode = cache.displayNode.object(forKey: key) {
          return .success(displayNode)
        }

        let atomList: AtomList
        switch self.atomList(for: latex, cache: &cache) {
        case .success(let parsed): atomList = parsed
        case .failure(let failure): return .failure(failure)
        }
        guard
          let displayNode = Typesetter.createLineForMathList(
            atomList,
            font: .init(font: font),
            style: .init(style),
            maxWidth: roundedWidth
          )
        else {
          return .failure(.typesettingFailed)
        }

        cache.displayNode.setObject(displayNode, forKey: key)

        if displayNode.width != roundedWidth {
          // Cache the measured width to avoid a miss between layout and draw passes
          let secondaryKey = KeyBox(
            Cache.Key(
              latex: latex,
              font: font,
              style: style,
              proposedWidth: displayNode.width.halfPointRounded()
            )
          )
          cache.displayNode.setObject(displayNode, forKey: secondaryKey)
        }

        return .success(displayNode)
      }
    }

    private func atomList(for latex: String, cache: inout Cache) -> Result<
      AtomList, RenderingFailure
    > {
      if let atomList = cache.atomList.object(forKey: latex as NSString) {
        return .success(atomList)
      }

      var error: ParserError?
      guard let atomList = Parser.build(fromString: latex, error: &error) else {
        return .failure(RenderingFailure(error))
      }

      cache.atomList.setObject(atomList, forKey: latex as NSString)
      return .success(atomList)
    }
  }
}

extension Math.Style.Level {
  fileprivate init(_ typesettingStyle: Math.TypesettingStyle) {
    switch typesettingStyle {
    case .display:
      self = .display
    case .text:
      self = .text
    }
  }
}

extension CGFloat {
  fileprivate func halfPointRounded() -> CGFloat {
    guard self > 0 else { return 0 }
    return (self * 2).rounded() / 2
  }
}
