import Foundation

extension Math {
  /// Explicit TeX delimiter size and spacing, independent of adjacent content height.
  final class SizedDelimiter: Atom {
    let command: String
    let sizeInEm: CGFloat

    init(command: String, delimiter: String, sizeInEm: CGFloat, spacing: AtomType) {
      self.command = command
      self.sizeInEm = sizeInEm
      super.init(type: spacing, nucleus: delimiter)
    }

    init(_ other: SizedDelimiter) {
      command = other.command
      sizeInEm = other.sizeInEm
      super.init(other)
    }

    static func specification(for command: String) -> (size: CGFloat, spacing: AtomType)? {
      var stem = command
      let spacing: AtomType
      switch stem.last {
      case "l":
        spacing = .open
        stem.removeLast()
      case "r":
        spacing = .close
        stem.removeLast()
      case "m":
        spacing = .relation
        stem.removeLast()
      default: spacing = .ordinary
      }
      let size: CGFloat
      switch stem {
      case "big": size = 1.2
      case "Big": size = 1.8
      case "bigg": size = 2.4
      case "Bigg": size = 3.0
      default: return nil
      }
      return (size, spacing)
    }
  }
}
