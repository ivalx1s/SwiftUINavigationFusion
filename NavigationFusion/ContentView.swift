import FusionCore
import SwiftUI

// MARK: - Route model ---------------------------------------------

enum AppRoute: Hashable {
    case home
    case detail(id: Int)
    case settings
}

// MARK: - Root scene ----------------------------------------------

@main
struct SampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavHost<AppRoute, HomeView>(strategy: .uikit) {
                HomeView()
            }
        }
    }
}

// MARK: - Home -----------------------------------------------------

struct HomeView: View {
    @State private var nextId = 1
    @Environment(\.anyNavigator) private var nav       // use anyNavigator
    
    var body: some View {
        VStack(spacing: 16) {
            Button("Push detail") {
                nav.push(
                    DetailView(id: nextId),
                    route: AppRoute.detail(id: nextId)
                )
                nextId += 1
            }
            
            Button("Open settings") {
                nav.push(SettingsView(),
                         route: AppRoute.settings)
            }
        }
        .navigationTitle("Home")
        .padding()
    }
}

// MARK: - Detail ---------------------------------------------------

struct DetailView: View {
    let id: Int
    @Environment(\.anyNavigator) private var nav
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Detail \(id)")
            
            Button("Pop")        { nav.pop() }
            Button("Pop to root"){ nav.popToRoot() }
        }
        .navigationTitle("Detail")
        .padding()
    }
}

// MARK: - Settings -------------------------------------------------

struct SettingsView: View {
    @Environment(\.anyNavigator) private var nav
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Settings")
            Button("Back") { nav.pop() }
        }
        .navigationTitle("Settings")
        .padding()
    }
}
