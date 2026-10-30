import Foundation

extension Math {
  final class Underbrace: Atom {
    var innerList: AtomList?

    override var finalized: Math.Atom {
      let finalized = super.finalized

      if let underbrace = finalized as? Underbrace {
        underbrace.innerList = underbrace.innerList?.finalized
      }

      return finalized
    }

    init(_ underbrace: Underbrace) {
      self.innerList = underbrace.innerList.map { AtomList($0) }
      super.init(underbrace)
    }

    init(innerList: AtomList? = nil) {
      self.innerList = innerList
      super.init(type: .underbrace)
    }
  }
}
