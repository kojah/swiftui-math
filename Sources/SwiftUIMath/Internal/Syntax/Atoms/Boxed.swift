import Foundation

extension Math {
  final class Boxed: Atom {
    var innerList: AtomList?

    override var finalized: Math.Atom {
      let finalized = super.finalized

      if let boxed = finalized as? Boxed {
        boxed.innerList = boxed.innerList?.finalized
      }

      return finalized
    }

    init(_ boxed: Boxed) {
      self.innerList = boxed.innerList.map { AtomList($0) }
      super.init(boxed)
    }

    init(innerList: AtomList? = nil) {
      self.innerList = innerList
      super.init(type: .boxed)
    }
  }
}
