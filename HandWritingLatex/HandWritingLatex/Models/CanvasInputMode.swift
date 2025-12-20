enum CanvasInputMode: String, CaseIterable {
    case pencilOnly
    case touchAndPencil

    var title: String {
        switch self {
        case .pencilOnly:
            return "Pencil"
        case .touchAndPencil:
            return "Touch"
        }
    }
}
