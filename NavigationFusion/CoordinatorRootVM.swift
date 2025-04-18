import SwiftUI

@MainActor
final class CoordinatorRootVM: ObservableObject {
    enum Action {
        case sheetMedium
        case sheetLarge
        case cover
        case pushDetail
    }

    private unowned let coordinator: ExampleCoordinator
    init(coordinator: ExampleCoordinator) { self.coordinator = coordinator }

    func handleViewAction(_ action: Action) {
        switch action {
        case .sheetMedium: coordinator.showSheet()
        case .sheetLarge:  coordinator.showLargeSheet()
        case .cover:       coordinator.showCover()
        case .pushDetail:  coordinator.pushDetail()
        }
    }
}
