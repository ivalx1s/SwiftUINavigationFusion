import SwiftUI
import UIKit

// MARK: – Navigator (imperative)
@MainActor
public struct Navigator {
    /// Deferred reference to the active `UINavigationController`.
    private let resolveNav: () -> UINavigationController?
    
    public init(resolveNav: @escaping () -> UINavigationController?) {
        self.resolveNav = resolveNav
    }
    
    // MARK: Push / Pop
    @MainActor
    public func push<V: View>(_ view: V, animated: Bool = true) {
        guard let nav = resolveNav() else { return }
        nav.pushViewController(UIHostingController(rootView: view), animated: animated)
    }
    
    @MainActor
    public func pop(animated: Bool = true) {
        resolveNav()?.popViewController(animated: animated)
    }
    
    @MainActor
    public func popToRoot(animated: Bool = true) {
        resolveNav()?.popToRootViewController(animated: animated)
    }
    
    /// Pops `levels` view‑controllers off the current navigation stack.
    /// - Parameters:
    ///   - levels:   How many view‑controllers to remove. Values ≤ 0 are ignored.
    ///   - animated: Whether the pop is animated.
    ///
    /// If *levels* is greater than or equal to the number of
    /// view‑controllers above the root, this falls back to `popToRoot`.
    @MainActor
    public func pop(levels: Int, animated: Bool = true) {
        guard levels > 0,                     // nothing to do for 0 / negatives
              let nav = resolveNav() else { return }
        
        let stack = nav.viewControllers
        let depth = stack.count
        guard depth > 1 else { return }       // already at root
        
        if levels >= depth - 1 {
            nav.popToRootViewController(animated: animated)
        } else {
            let target = stack[depth - levels - 1]
            nav.popToViewController(target, animated: animated)
        }
    }
    
    // ──────────────────────────────────────────────
    // MARK: Modal helpers
    // ──────────────────────────────────────────────
    
    /// Presents content inside a brand‑new `UINavigationController`
    /// shown as a *page sheet*. Any later `push`/`pop` calls executed
    /// with the supplied `Navigator` are confined to that sheet.
    @MainActor
    public func presentSheet<V: View>(
        detents: [UISheetPresentationController.Detent]? = nil,
        prefersGrabberVisible grabber: Bool = false,
        animated: Bool = true,
        @ViewBuilder content: (Navigator) -> V
    ) {
        // 1. Build an isolated nav‑stack for the sheet
        let sheetNav = UINavigationController()
        let sheetNavigator = Navigator(resolveNav: { sheetNav })
        
        // 2. Insert caller’s content as the root
        let rootVC = UIHostingController(rootView: content(sheetNavigator))
        sheetNav.viewControllers = [rootVC]
        sheetNav.modalPresentationStyle = .pageSheet
        
        if let sheet = sheetNav.sheetPresentationController {
            sheet.detents = detents ?? [.medium(), .large()]
            sheet.prefersGrabberVisible = grabber
        }
        
        topPresenter?.present(sheetNav, animated: animated)
    }
    
    /// Legacy overload – still available, but now wraps the supplied
    /// view inside its own nav‑stack so push/pop stay within the sheet.
    @MainActor
    public func presentSheet<V: View>(
        _ view: V,
        detents: [UISheetPresentationController.Detent]? = nil,
        prefersGrabberVisible grabber: Bool = false,
        animated: Bool = true
    ) {
        presentSheet(detents: detents,
                     prefersGrabberVisible: grabber,
                     animated: animated) { _ in view }
    }
    
    /// Presents content full‑screen, wrapped in its own `UINavigationController`.
    /// Subsequent `push`/`pop` calls affect only that cover’s stack.
    @MainActor
    public func presentFullScreen<V: View>(
        animated: Bool = true,
        @ViewBuilder content: (Navigator) -> V
    ) {
        let coverNav = UINavigationController()
        let coverNavigator = Navigator(resolveNav: { coverNav })
        
        let rootVC = UIHostingController(rootView: content(coverNavigator))
        coverNav.viewControllers = [rootVC]
        coverNav.modalPresentationStyle = .fullScreen
        
        topPresenter?.present(coverNav, animated: animated)
    }
    
    /// Legacy overload – keeps the old signature but now provides its own
    /// navigation stack so that push/pop remain local to the cover.
    @MainActor
    public func presentFullScreen<V: View>(
        _ view: V,
        animated: Bool = true
    ) {
        presentFullScreen(animated: animated) { _ in view }
    }
    
    /// Dismisses the modal (sheet or full‑screen cover) that this `Navigator`
    /// belongs to, no matter how deep the current view is in the stack.
    @MainActor
    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        // If we have a nav stack, dismiss *it* – that’s the modal root.
        if let nav = resolveNav() {
            nav.dismiss(animated: animated, completion: completion)
        } else {
            // Fallback: dismiss whatever is currently presented.
            topPresenter?.dismiss(animated: animated, completion: completion)
        }
    }
    
    // ──────────────────────────────────────────────
    // MARK: Private helpers
    // ──────────────────────────────────────────────
    
    /// Safely finds the *upper‑most* view‑controller that can present modals.
    private var topPresenter: UIViewController? {
        guard let navController = resolveNav() else { return nil }
        var candidate: UIViewController = navController
        
        while let presented = candidate.presentedViewController {
            candidate = presented
        }
        // If that’s a nav or tab controller, drill into the visible child.
        if let nav = candidate as? UINavigationController {
            return nav.topViewController ?? nav
        }
        if let tab = candidate as? UITabBarController {
            return tab.selectedViewController ?? tab
        }
        return candidate
    }
}
