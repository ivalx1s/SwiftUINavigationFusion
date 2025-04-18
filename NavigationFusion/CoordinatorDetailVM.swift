import SwiftUI

@MainActor
final class CoordinatorDetailVM: ObservableObject {
    enum Action {
        case sheetMedium
        case sheetLarge
        case pop
        case popTwo
        case popMany
        case popRoot
    }

    private unowned let coordinator: ExampleCoordinator
    init(coordinator: ExampleCoordinator) { self.coordinator = coordinator }

    func handleViewAction(_ action: Action) {
        switch action {
        case .sheetMedium: coordinator.showSheet()
        case .sheetLarge:  coordinator.showLargeSheet()
        case .pop:         coordinator.pop()
        case .popTwo:      coordinator.pop(levels: 2)
        case .popMany:     coordinator.pop(levels: 20)
        case .popRoot:     coordinator.popToRoot()
        }
    }
}
