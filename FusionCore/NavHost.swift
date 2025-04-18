import SwiftUI
import UIKit

// MARK: – Navigator (imperative)



public struct Navigator {
    /// Deferred reference to the active `UINavigationController`.
    private let resolveNav: () -> UINavigationController?
    
    /// Designated initializer.  Made **public** so you can create a `Navigator`
    /// outside this module (e.g. in unit tests or custom containers).
    public init(resolveNav: @escaping () -> UINavigationController?) {
        self.resolveNav = resolveNav
    }
    
    // MARK: Push / Pop helpers
    /// Pushes a SwiftUI `View` onto the underlying `UINavigationController`.
    public func push<V: View>(_ view: V, animated: Bool = true) {
        guard let nav = resolveNav() else { return }
        nav.pushViewController(UIHostingController(rootView: view), animated: animated)
    }
    
    /// Pops the top view‑controller if possible.
    public func pop(animated: Bool = true) {
        resolveNav()?.popViewController(animated: animated)
    }
    
    /// Pops to the root of the navigation stack.
    public func popToRoot(animated: Bool = true) {
        resolveNav()?.popToRootViewController(animated: animated)
    }
}

// MARK: – NavHost (UIKit only)

public struct NavHost<Root: View>: UIViewControllerRepresentable {
    private let rootBuilder: (Navigator) -> Root
    
    /// Creates a `NavHost` that embeds the given SwiftUI view hierarchy
    /// in a `UINavigationController` and provides a `Navigator` to the builder.
    public init(@ViewBuilder root: @escaping (Navigator) -> Root) {
        self.rootBuilder = root
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        let nav = UINavigationController()
        let navigator = Navigator(resolveNav: { nav })
        
        let rootVC = UIHostingController(rootView: rootBuilder(navigator))
        nav.viewControllers = [rootVC]
        return nav
    }
    
    public func updateUIViewController(_: UIViewController, context: Context) {}
}
