import UIKit

final class TabBarController: UITabBarController {
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpAppearance()
        configureViewControllers()
    }
}

// MARK: - Extensions + Private TabBarController Setting Up Views
private extension TabBarController {
    func setUpAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .ypBlue
        tabBar.standardAppearance = tabBarAppearance
    }

    func configureViewControllers() {
        let trackerViewController = TrackersViewController()
        trackerViewController.tabBarItem =
        UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .tabBarTrackersTab),
            tag: 0
        )
        
        let statisticViewController = StatisticViewController()
        statisticViewController.tabBarItem =
        UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .tabBarStatisticTab),
            tag: 1
        )
        
        setViewControllers([
            UINavigationController(rootViewController: trackerViewController),
            UINavigationController(rootViewController: statisticViewController)
        ], animated: true)
    }
}
