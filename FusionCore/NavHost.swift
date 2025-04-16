//  NavigationCore.swift
//  Clean compile‑ready navigation core (UIKit‑driven for MVP)
//  • Generic over Route
//  • Imperative Navigator with push/pop
//  • AnyNavigator type‑erased in Environment
//  • NavHost root container (UIKit only until SwiftUI mapping is added)

import SwiftUI
import UIKit
import Combine

// MARK: – Strategy selection

public enum NavigationStackStrategy {
    case uikit       // always drive UINavigationController
    case swiftUI     // use NavigationStack (future)
    
    public static var current: NavigationStackStrategy {
        if #available(iOS 17.0, *) { .uikit /* keep UIKit for now */ } else { .uikit }
    }
}

// MARK: – NavStore

public final class NavStore<Route: Hashable>: ObservableObject {
    @Published public var path: [Route] = []
}

// MARK: – Navigator (imperative)

public struct Navigator<Route: Hashable> {
    private let resolveNav: () -> UINavigationController?
    private let store: NavStore<Route>
    
    init(resolveNav: @escaping () -> UINavigationController?, store: NavStore<Route>) {
        self.resolveNav = resolveNav
        self.store = store
    }
    
    public func push<V: View>(_ view: V, route: Route, animated: Bool = true) {
        guard let nav = resolveNav() else { return }
        let wrapped = view
            .environment(\.anyNavigator, AnyNavigator(self))
            .environmentObject(store)
        nav.pushViewController(UIHostingController(rootView: wrapped), animated: animated)
        store.path.append(route)
    }
    
    public func pop(animated: Bool = true) {
        guard let nav = resolveNav(), !store.path.isEmpty else { return }
        nav.popViewController(animated: animated)
        _ = store.path.popLast()
    }
    
    public func popToRoot(animated: Bool = true) {
        guard let nav = resolveNav() else { return }
        nav.popToRootViewController(animated: animated)
        store.path.removeAll()
    }
}

// MARK: – AnyNavigator (type‑erased)

public struct AnyNavigator {
    private let _push: (AnyView, AnyHashable) -> Void
    private let _pop: () -> Void
    private let _popRoot: () -> Void
    
    init<R: Hashable>(_ navigator: Navigator<R>) {
        _push = { view, route in
            guard let r = route as? R else { return }
            navigator.push(view, route: r)
        }
        _pop = { navigator.pop() }
        _popRoot = { navigator.popToRoot() }
    }
    
    public func push<V: View>(_ view: V, route: AnyHashable) { _push(AnyView(view), route) }
    public func pop() { _pop() }
    public func popToRoot() { _popRoot() }
}

private struct AnyNavigatorKey: EnvironmentKey {
    static let defaultValue = AnyNavigator(Navigator(resolveNav: { nil }, store: NavStore<AnyHashable>()))
}

public extension EnvironmentValues {
    var anyNavigator: AnyNavigator {
        get { self[AnyNavigatorKey.self] }
        set { self[AnyNavigatorKey.self] = newValue }
    }
}

// MARK: – NavHost (UIKit only for MVP)

public struct NavHost<Route: Hashable, Root: View>: UIViewControllerRepresentable {
    private let rootBuilder: () -> Root
    @StateObject private var store = NavStore<Route>()
    
    public init(@ViewBuilder root: @escaping () -> Root) {
        self.rootBuilder = root
    }
    
    /// Convenience initializer that accepts a `NavigationStackStrategy`. For now the
    /// strategy is ignored because only the UIKit branch is implemented
    public init(strategy _: NavigationStackStrategy, @ViewBuilder root: @escaping () -> Root) {
        self.rootBuilder = root
    }
    
    public func makeUIViewController(context: Context) -> UIViewController {
        let nav = UINavigationController()
        let navProxy = Navigator<Route>(resolveNav: { nav }, store: store)
        let rootVC = UIHostingController(rootView: rootBuilder()
            .environmentObject(store)
            .environment(\.anyNavigator, AnyNavigator(navProxy)))
        nav.viewControllers = [rootVC]
        return nav
    }
    
    public func updateUIViewController(_: UIViewController, context: Context) {}
}

// MARK: – Bridging modifiers

public struct NavigationBridgeItemModifier<Item: Identifiable & Hashable, Dest: View>: ViewModifier {
    @Binding var item: Item?
    let destination: (Item) -> Dest
    @Environment(\.anyNavigator) private var nav
    
    public func body(content: Content) -> some View {
        content.onChange(of: item) { value in
            guard let value else { return }
            nav.push(destination(value), route: value)
            DispatchQueue.main.async { self.item = nil }
        }
    }
}

public struct NavigationBridgeFlagModifier<Dest: View>: ViewModifier {
    @Binding var isActive: Bool
    let buildDest: () -> Dest
    @Environment(\.anyNavigator) private var nav
    
    public func body(content: Content) -> some View {
        content.onChange(of: isActive) { active in
            guard active else { return }
            nav.push(buildDest(), route: UUID())
            DispatchQueue.main.async { self.isActive = false }
        }
    }
}

public extension View {
    func nav<Item: Identifiable & Hashable, Dest: View>(item: Binding<Item?>, @ViewBuilder destination: @escaping (Item) -> Dest) -> some View {
        modifier(NavigationBridgeItemModifier(item: item, destination: destination))
    }
    
    func nav<Dest: View>(isActive: Binding<Bool>, @ViewBuilder destination: @escaping () -> Dest) -> some View {
        modifier(NavigationBridgeFlagModifier(isActive: isActive, buildDest: destination))
    }
}
