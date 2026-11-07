import Foundation

extension Math {
  /// A relation with a centered, script-sized annotation above its base.
  final class StackRelation: Atom {
    var annotation: AtomList
    var base: AtomList

    init(annotation: AtomList, base: AtomList) {
      self.annotation = annotation
      self.base = base
      super.init(type: .relation)
    }

    init(_ other: StackRelation) {
      annotation = AtomList(other.annotation)
      base = AtomList(other.base)
      super.init(other)
    }

    override var finalized: Atom {
      let result = super.finalized
      if let stack = result as? StackRelation {
        stack.annotation = stack.annotation.finalized
        stack.base = stack.base.finalized
      }
      return result
    }
  }
}
