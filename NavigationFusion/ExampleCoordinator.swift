import FusionCore
import SwiftUI


// MARK: – Coordinator pattern demo
// ---------------------------------

/// Owns a `Navigator` and drives all navigation imperatively.
@MainActor
final class ExampleCoordinator: ObservableObject {
    let navigator: Navigator
    
    init(navigator: Navigator) { self.navigator = navigator }
    
    // Entry‑point
    func view() -> some View {
        CoordinatorRootView(coordinator: self)
    }
    
    // MARK: Navigation actions
    func showDetails() {
        navigator.push(CoordinatorDetailView(coordinator: self))
    }
    
    func showSheet() {
        navigator.presentSheet { nav in SheetContent(navigator: nav) }
    }
    
    func showLargeSheet() {
        navigator.presentSheet(detents: [.large()],
                               prefersGrabberVisible: true) { nav in
            SheetContent(navigator: nav)
        }
    }
    
    func showCover() {
        navigator.presentFullScreen { nav in CoverContent(navigator: nav) }
    }
}

/// Root view that delegates all button taps to the coordinator.
struct CoordinatorHost: View {
    let navigator: Navigator
    @StateObject private var coordinator: ExampleCoordinator
    
    init(navigator: Navigator) {
        self.navigator = navigator
        _coordinator = StateObject(wrappedValue: ExampleCoordinator(navigator: navigator))
    }
    
    var body: some View { coordinator.view() }
}

// UI mirroring `HomeView`
struct CoordinatorRootView: View {
    @ObservedObject var coordinator: ExampleCoordinator
    
    var body: some View {
        VStack(spacing: 24) {
            
            // ── Sheet demos ─────────────────────────────────────
            Group {
                Text("Sheets").font(.headline)
                Button("Sheet – medium/large") {
                    coordinator.showSheet()
                }
                Button("Sheet – custom large (grabber)") {
                    coordinator.showLargeSheet()
                }
            }
            
            Divider().padding(.vertical, 8)
            
            // ── Full‑screen cover demo ──────────────────────────
            Group {
                Text("Full‑screen Covers").font(.headline)
                Button("Open cover") {
                    coordinator.showCover()
                }
            }
            
            Divider().padding(.vertical, 8)
            
            // ── Navigation push demo ────────────────────────────
            Group {
                Text("Navigation Push").font(.headline)
                Button("Push detail") {
                    coordinator.showDetails()
                }
            }
        }
        .padding()
        .navigationTitle("Coord Home")
    }
}

// Detail view with the same capabilities as `DetailView`
struct CoordinatorDetailView: View {
    @ObservedObject var coordinator: ExampleCoordinator
    
    var body: some View {
        let nav = coordinator.navigator
        VStack(spacing: 16) {
            Button("Open sheet") {
                coordinator.showSheet()
            }
            Button("Open full‑size sheet") {
                coordinator.showLargeSheet() }
            Button("Pop") {
                nav.pop()
            }
            Button("Pop 2") {
                nav.pop(levels: 2)
            }
            Button("Pop 20 or to root") {
                nav.pop(levels: 20)
            }
            Button("Pop to root") {
                nav.popToRoot()
            }
        }
        .padding()
        .navigationTitle("Coord Detail")
    }
}
