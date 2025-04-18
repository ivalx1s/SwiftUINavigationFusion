import SwiftUI
import UIKit

// MARK: – NavHost (UIKit only)

public struct Navigation<Root: View>: UIViewControllerRepresentable {
    private let rootBuilder: (Navigator) -> Root
    
    /// Creates a `NavHost` that embeds the given SwiftUI view hierarchy
    /// in a `UINavigationController` and provides a `Navigator` to the builder.
    public init(@ViewBuilder root: @escaping (Navigator) -> Root) {
        self.rootBuilder = root
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        let nav = UINavigationController()
        let navigator = Navigator(resolveNav: { [weak nav] in nav })
        
        let rootVC = UIHostingController(rootView: rootBuilder(navigator))
        nav.viewControllers = [rootVC]
        return nav
    }
    
    public func updateUIViewController(_: UIViewController, context: Context) {}
}
