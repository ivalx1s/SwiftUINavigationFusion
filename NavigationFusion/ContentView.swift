import FusionCore
import SwiftUI

@main
struct SampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavHost { navigator in
                HomeView(navigator: navigator)
            }
        }
    }
}

struct HomeView: View {
    let navigator: Navigator
    @State private var nextId = 1
    
    var body: some View {
        VStack(spacing: 16) {
            Button("Push detail") {
                navigator.push(DetailView(navigator: navigator))
                nextId += 1
            }
            
            Button("Open settings") {
                navigator.push(SettingsView(navigator: navigator))
            }
        }
        .navigationTitle("Home")
        .padding()
    }
}

struct DetailView: View {
    let navigator: Navigator
    
    var body: some View {
        VStack(spacing: 16) {
            Button("Pop")        { navigator.pop() }
            Button("Pop to root"){ navigator.popToRoot() }
        }
        .navigationTitle("Detail")
        .padding()
    }
}

struct SettingsView: View {
    let navigator: Navigator
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Settings")
            Button("Back") { navigator.pop() }
        }
        .navigationTitle("Settings")
        .padding()
    }
}
