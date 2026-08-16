import UIKit

enum AppNavigator {

    static func showMainApp(from viewController: UIViewController) {
        guard let window = viewController.view.window else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBar = storyboard.instantiateViewController(
            withIdentifier: "MainTabBarController"
        ) as? UITabBarController else {
            return
        }

        UIView.transition(
            with: window,
            duration: 0.35,
            options: .transitionCrossDissolve
        ) {
            window.rootViewController = tabBar
        }
    }

    static func showLogin(from viewController: UIViewController) {
        guard let window = viewController.view.window else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let loginNav = storyboard.instantiateViewController(
            withIdentifier: "LoginNavigationController"
        ) as? UINavigationController else {
            return
        }

        UIView.transition(
            with: window,
            duration: 0.35,
            options: .transitionCrossDissolve
        ) {
            window.rootViewController = loginNav
        }
    }
}
