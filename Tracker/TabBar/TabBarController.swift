import UIKit

class AppTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
    }
    
    func setupViewControllers() {
        let trackerController = TrackersViewController()
        let firstVC = createNavController(for: trackerController,
                                          title: "Трекеры",
                                          image: UIImage(named: "tab1")!)
        let thirdVC = createNavController(for: ThirdViewController(),
                                          title: "Статистика",
                                          image: UIImage(named: "tab2")!)
        
        viewControllers = [firstVC, thirdVC]
        
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .gray
        tabBar.backgroundColor = .systemBackground
        
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.shadowColor = .black
            tabBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func createNavController(for rootViewController: UIViewController,
                                     title: String,
                                     image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        return navController
    }
}

class ThirdViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}
