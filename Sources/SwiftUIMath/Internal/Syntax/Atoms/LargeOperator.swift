import Foundation

extension Math {
  final class LargeOperator: Atom {
    var limits: Bool
    var isNamedOperator = false
    var usesDisplayLimits = false

    init(_ largeOperator: LargeOperator) {
      self.limits = largeOperator.limits
      self.isNamedOperator = largeOperator.isNamedOperator
      self.usesDisplayLimits = largeOperator.usesDisplayLimits
      super.init(largeOperator)
    }

    init(limits: Bool = false) {
      self.limits = limits
      super.init(type: .largeOperator)
    }
  }
}
