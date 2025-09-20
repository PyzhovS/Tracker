import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        
               UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
        
        window = UIWindow(windowScene: windowScene)
        
    
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        print("hasSeenOnboarding: \(hasSeenOnboarding)")
        
        if hasSeenOnboarding {
 
            print("Showing tab bar")
            window?.rootViewController = AppTabBarController()
        } else {

            print("Showing onboarding")
            let onboardingVC = OnboardingPageViewController(
                transitionStyle: .scroll,
                navigationOrientation: .horizontal,
                options: nil
            )
            window?.rootViewController = onboardingVC
        }
        
        window?.makeKeyAndVisible()
        

        _ = CoreDataManager.shared.persistentContainer
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        CoreDataManager.shared.saveContext()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        CoreDataManager.shared.saveContext()
    }
}
