import UIKit

struct FormulaItem: Identifiable {
    let id: UUID
    let snapshot: UIImage
    let timestamp: Date
    var state: FormulaState
}

enum FormulaState {
    case processing
    case success(latex: String, engine: String)
    case failure(message: String)
}
