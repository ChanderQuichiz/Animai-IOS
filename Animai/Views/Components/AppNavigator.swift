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

    static func handleSessionExpired(from viewController: UIViewController? = nil) {
        let topVC = viewController ?? getTopViewController()

        guard let targetVC = topVC else { return }

        // Evitar múltiples alertas si ya se está mostrando una
        if targetVC is UIAlertController { return }

        let alert = UIAlertController(
            title: "Sesión Vencida",
            message: "Tu sesión ha expirado por seguridad. Por favor, inicia sesión nuevamente.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { _ in
            AuthService.shared.logout()
            showLogin(from: targetVC)
        })

        targetVC.present(alert, animated: true)
    }

    private static func getTopViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first

        var topController = keyWindow?.rootViewController
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        return topController
    }
}
