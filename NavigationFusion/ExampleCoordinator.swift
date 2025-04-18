import FusionCore
import SwiftUI

@MainActor
final class ExampleCoordinator: ObservableObject {
    let navigator: Navigator

    init(navigator: Navigator) {
        self.navigator = navigator
    }

    func start() -> some View {
        CoordinatorRootView(coordinator: self)
    }

    // Example of an action handled by the coordinator
    func showDetails() {
        navigator.push(CoordinatorDetailView(coordinator: self))
    }
}

/// Entry‑point view that simply hands off to `ExampleCoordinator`.
struct CoordinatorHost: View {
    let navigator: Navigator
    @StateObject private var coordinator: ExampleCoordinator

    init(navigator: Navigator) {
        self.navigator = navigator
        _coordinator = StateObject(wrappedValue: ExampleCoordinator(navigator: navigator))
    }

    var body: some View {
        coordinator.start()
    }
}

struct CoordinatorRootView: View {
    @ObservedObject var coordinator: ExampleCoordinator

    var body: some View {
        VStack(spacing: 16) {
            Text("Coordinator Root")
            Button("Show details") {
                coordinator.showDetails()
            }
        }
        .padding()
        .navigationTitle("Coord Root")
    }
}

struct CoordinatorDetailView: View {
    @ObservedObject var coordinator: ExampleCoordinator

    var body: some View {
        VStack(spacing: 16) {
            Text("Coordinator Detail")
            Button("Pop") { coordinator.navigator.pop() }
            Button("Pop to root") { coordinator.navigator.popToRoot() }
        }
        .padding()
        .navigationTitle("Coord Detail")
    }
}
