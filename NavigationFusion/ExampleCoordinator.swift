import FusionCore
import SwiftUI


// MARK: – Coordinator pattern demo
// ---------------------------------

/// Owns a `Navigator` and drives all navigation imperatively.
@MainActor
final class ExampleCoordinator: ObservableObject {
    let navigator: Navigator
    init(navigator: Navigator) { self.navigator = navigator }
    
    // ── Navigation helpers ───────────────────────────────
    func pushDetail()           { navigator.push(makeDetailView()) }
    func showSheet()            { navigator.presentSheet { nav in SheetContent(navigator: nav) } }
    func showLargeSheet()       { navigator.presentSheet(detents: [.large()], prefersGrabberVisible: true) { nav in SheetContent(navigator: nav) } }
    func showCover()            { navigator.presentFullScreen { nav in CoverContent(navigator: nav) } }
    func pop()                  { navigator.pop() }
    func pop(levels: Int)       { navigator.pop(levels: levels) }
    func popToRoot()            { navigator.popToRoot() }
    
    // View factories keep SwiftUI construction in one place
    func makeRootView()  -> some View { CoordinatorRootView(coordinator: self) }
    func makeDetailView() -> some View { CoordinatorDetailView(coordinator: self) }
}

/// Root view that delegates all button taps to the coordinator.
struct CoordinatorHost: View {
    let navigator: Navigator
    @StateObject private var coordinator: ExampleCoordinator
    
    init(navigator: Navigator) {
        _coordinator = StateObject(wrappedValue: ExampleCoordinator(navigator: navigator))
        self.navigator = navigator
    }
    var body: some View { coordinator.makeRootView() }
}

/// Mirrors `HomeView` but delegates via ViewModel›Coordinator.
struct CoordinatorRootView: View {
    @StateObject private var viewModel: CoordinatorRootVM
    
    init(coordinator: ExampleCoordinator) {
        _viewModel = StateObject(wrappedValue: CoordinatorRootVM(coordinator: coordinator))
    }

    
    var body: some View {
        VStack(spacing: 24) {
            Group {
                Text("Sheets").font(.headline)
                Button("Sheet – medium/large") { viewModel.handleViewAction(.sheetMedium) }
                Button("Sheet – custom large (grabber)") { viewModel.handleViewAction(.sheetLarge) }
            }
            
            Divider().padding(.vertical, 8)
            
            Group {
                Text("Full‑screen Covers").font(.headline)
                Button("Open cover") { viewModel.handleViewAction(.cover) }
            }
            
            Divider().padding(.vertical, 8)
            
            Group {
                Text("Navigation Push").font(.headline)
                Button("Push detail") { viewModel.handleViewAction(.pushDetail) }
            }
        }
        .padding()
        .navigationTitle("Coord Home")
    }
}

/// Mirrors `DetailView` with ViewModel delegation.
struct CoordinatorDetailView: View {
    @StateObject private var viewModel: CoordinatorDetailVM
    
    init(coordinator: ExampleCoordinator) {
        _viewModel = StateObject(wrappedValue: CoordinatorDetailVM(coordinator: coordinator))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Button("Open sheet")             { viewModel.handleViewAction(.sheetMedium) }
            Button("Open full‑size sheet")   { viewModel.handleViewAction(.sheetLarge) }
            Button("Pop")                    { viewModel.handleViewAction(.pop) }
            Button("Pop 2")                  { viewModel.handleViewAction(.popTwo) }
            Button("Pop 20 or to root")      { viewModel.handleViewAction(.popMany) }
            Button("Pop to root")            { viewModel.handleViewAction(.popRoot) }
        }
        .padding()
        .navigationTitle("Coord Detail")
    }
}
