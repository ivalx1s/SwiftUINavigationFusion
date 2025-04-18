import FusionCore
import SwiftUI

@main
struct SampleApp: App {
    var body: some Scene {
        WindowGroup {
            Navigation { navigator in
                HomeView(navigator: navigator)
            }
        }
    }
}

struct HomeView: View {
    let navigator: Navigator
    
    var body: some View {
        VStack(spacing: 24) {
            
            // ── Sheet demos ─────────────────────────────────────
            Group {
                Text("Sheets").font(.headline)
                
                Button("Sheet – medium/large") {
                    navigator.presentSheet { nav in
                        SheetContent(navigator: nav)
                    }
                }
                
                Button("Sheet – custom large (grabber)") {
                    navigator.presentSheet(
                        detents: [.large()],
                        prefersGrabberVisible: true
                    ) { nav in
                        SheetContent(navigator: nav)
                    }
                }
            }
            
            Divider()
                .padding(.vertical, 8)
            
            // ── Full‑screen cover demos ─────────────────────────
            Group {
                Text("Full‑screen Covers").font(.headline)
                
                Button("Open cover") {
                    navigator.presentFullScreen { nav in
                        CoverContent(navigator: nav)
                    }
                }
            }
            
            Divider().padding(.vertical, 8)
            
            // ── Navigation push demo ────────────────────────────
            Group {
                Text("Navigation Push").font(.headline)
                
                Button("Push detail") {
                    navigator.push(DetailView(navigator: navigator))
                }
            }
        }
        .padding()
        .navigationTitle("Home")
    }
}

// MARK: – Demo content shown in a sheet
struct SheetContent: View {
    let navigator: Navigator
    
    var body: some View {
        VStack(spacing: 16) {
            Text("This is a sheet 🎉")
            
            Button("Dismiss sheet") {
                navigator.dismiss()
            }
            
            Button("Push detail from sheet") {
                navigator.push(DetailView(navigator: navigator))
            }
            
            Button("Push deep view & dismiss there") {
                navigator.push(DeepView(navigator: navigator))
            }
        }
        .padding()
        .navigationTitle("Sheet")
    }
}

// MARK: – Demo content shown full‑screen
struct CoverContent: View {
    let navigator: Navigator
    
    var body: some View {
        VStack(spacing: 16) {
            Text("This is a full‑screen cover 🖥️")
            
            Button("Dismiss cover") {
                navigator.dismiss()
            }
            
            Button("Push detail from cover") {
                navigator.push(DetailView(navigator: navigator))
            }
            
            Button("Push deep view & dismiss there") {
                navigator.push(DeepView(navigator: navigator))
            }
        }
        .padding()
        .navigationTitle("Cover")
    }
}

// MARK: – Demonstrates dismissing from deep in the stack
struct DeepView: View {
    let navigator: Navigator
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Deep inside 🚀")
            Button("Dismiss modal") { navigator.dismiss() }
        }
        .padding()
        .navigationTitle("Deep")
    }
}

struct DetailView: View {
    let navigator: Navigator
    
    var body: some View {
        VStack(spacing: 16) {
            Button("Open sheet") {
                navigator.presentSheet { nav in
                    SheetContent(navigator: nav)
                }
            }
            Button("Open full‑size sheet") {
                navigator.presentSheet(
                    detents: [.large()],
                    prefersGrabberVisible: true
                ) { nav in
                    SheetContent(navigator: nav)
                }
            }
            Button("Pop")        { navigator.pop() }
            Button("Pop 2")      { navigator.pop(levels: 2) }
            Button("Pop 20 or to root")      { navigator.pop(levels: 20) }
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
            Button("Dismiss") { navigator.dismiss() }
            Button("Pop") { navigator.pop() }
        }
        .navigationTitle("Settings")
        .padding()
    }
}
