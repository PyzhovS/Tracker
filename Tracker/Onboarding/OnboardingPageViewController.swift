import UIKit

// MARK: - OnboardingPageViewControllerDelegate
protocol OnboardingPageViewControllerDelegate: AnyObject {
    func onboardingDidFinish()
}

// MARK: - OnboardingPageViewController
final class OnboardingPageViewController: UIPageViewController {
    
    // MARK: - Properties
    private var pages: [UIViewController] = []
    private let pageControl = UIPageControl()
    private var currentIndex: Int = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPages()
        setupUI()
        setupPageControl()
    }
    
    // MARK: - Private Methods
    private func setupPages() {
        let page1 = OnboardingViewController(
            title: Localizable.Onboarding.page1Title,
            imageName: "onboarding1",
            pageIndex: 0
        )
        
        let page2 = OnboardingViewController(
            title: Localizable.Onboarding.page2Title,
            imageName: "onboarding2",
            pageIndex: 1
        )
        
        pages = [page1, page2]
        
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
        
        dataSource = self
        delegate = self
    }
    
    private func setupUI() {
        view.backgroundColor = .white
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
        
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -168),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func pageControlTapped(_ sender: UIPageControl) {
        let direction: UIPageViewController.NavigationDirection
        if sender.currentPage > currentIndex {
            direction = .forward
        } else {
            direction = .reverse
        }
        
        guard sender.currentPage < pages.count else {
            print("Ошибка: неверный индекс страницы")
            return
        }
        
        let selectedViewController = pages[sender.currentPage]
        
        setViewControllers([selectedViewController],
                           direction: direction,
                           animated: true) { [weak self] _ in
            self?.currentIndex = sender.currentPage
        }
    }
    
    // MARK: - Navigation
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        let tabBarController = AppTabBarController()
        
        guard let window = UIApplication.shared.windows.first else { return }
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = tabBarController
        }, completion: nil)
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else {
            return nil
        }
        return pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < pages.count - 1 else {
            return nil
        }
        return pages[currentIndex + 1]
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            self.currentIndex = currentIndex
            pageControl.currentPage = currentIndex
        }
    }
}
