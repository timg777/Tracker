import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - Internal Properties
    var window: UIWindow?

    // MARK: - Scene managing
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        
        let rootViewController: UIViewController
        
        if UserDefaultsService.shared.isOnboardingCompleted {
            rootViewController = TabBarController()
        } else {
            let vc = OnboardingViewController()
            vc.didTapOnboardingSkipButton = { [weak self] in
                guard let self else { return }
                UserDefaultsService.shared.isOnboardingCompleted = true
                window?.rootViewController = TabBarController()
            }
            rootViewController = vc
        }
        
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
    
    // MARK: - Temporary unused methods
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

