import UIKit

// MARK: - AppTabBarController
class AppTabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBarAppearance()
    }
    
    // MARK: - Setup
    func setupViewControllers() {
        let trackerController = TrackersViewController()
        let firstVC = createNavController(for: trackerController,
                                          title: Localizable.Tabbar.trackers,
                                          image: UIImage(resource: .tab1))
        
        let statisticsController = StatisticsViewController()
        let thirdVC = createNavController(for: statisticsController,
                                          title: Localizable.Tabbar.statistics,
                                          image: UIImage(resource: .tab2))
        
        viewControllers = [firstVC, thirdVC]
        
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .gray
    }
    
    private func setupTabBarAppearance() {
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            appearance.shadowColor = .gray
            tabBar.standardAppearance = appearance
            
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        }
    }
    
    // MARK: - Factory
    private func createNavController(for rootViewController: UIViewController,
                                     title: String,
                                     image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        return navController
    }
}
