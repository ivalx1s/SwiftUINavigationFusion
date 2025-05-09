import SwiftUI
import FusionCore

@main
struct SampleApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                // ── Tab 1: Plain navigator in view demo ─────────────────────────
                Navigation { navigator in
                    HomeView(navigator: navigator)
                }
                .tabItem {
                    Label("Demo", systemImage: "1.square")
                }
                
                // ── Tab 2: Navigator + Coordinator demo ─────────────────────
                Navigation { navigator in
                    CoordinatorHost(navigator: navigator)
                }
                .tabItem {
                    Label("Coordinator", systemImage: "2.square")
                }
            }
        }
    }
}
