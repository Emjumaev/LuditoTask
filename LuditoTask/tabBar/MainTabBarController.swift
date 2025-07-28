import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    private let customTabBarBackground = UIView()
    private let separator = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setValue(CustomTabBar(), forKey: "tabBar")
        setupCustomTabBarBackground()
        setupTabBarAppearance()
        setupTabBarControllers()
        
        selectedIndex = 1
    }
    
    private func setupCustomTabBarBackground() {
        guard let tabBarSuperview = tabBar.superview else { return }
        customTabBarBackground.backgroundColor = .white
        customTabBarBackground.layer.cornerRadius = 8
        customTabBarBackground.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        customTabBarBackground.layer.masksToBounds = false
        customTabBarBackground.layer.shadowColor = UIColor(hex: "#DCDCDC66").cgColor
        customTabBarBackground.layer.shadowOpacity = 0.4
        customTabBarBackground.layer.shadowOffset = CGSize(width: 0, height: 0)
        customTabBarBackground.layer.shadowRadius = 3
        customTabBarBackground.translatesAutoresizingMaskIntoConstraints = false
        tabBarSuperview.insertSubview(customTabBarBackground, belowSubview: tabBar)
        NSLayoutConstraint.activate([
            customTabBarBackground.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            customTabBarBackground.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            customTabBarBackground.topAnchor.constraint(equalTo: tabBar.topAnchor),
            customTabBarBackground.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor)
        ])
    }
    
    private func setupTabBarAppearance() {
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.backgroundColor = .clear
        tabBar.isTranslucent = true
        tabBar.layer.backgroundColor = UIColor.clear.cgColor
        tabBar.tintColor = .black
    }
    
    private func setupTabBarControllers() {
        let vc1 = UINavigationController(rootViewController: FavoriteViewController())
        vc1.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "bookmark_unselected"), selectedImage: UIImage(named: "bookmark_selected"))

        let vc2 = UINavigationController(rootViewController: YandexMapsViewController())
        vc2.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "map_unselected"), selectedImage: UIImage(named: "map_unselected"))

        let vc3 = UINavigationController(rootViewController: ProfileViewController())
        vc3.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "profile_unselected_icon"), selectedImage: UIImage(named: "profile_unselected_icon"))

        viewControllers = [vc1, vc2, vc3]
    }
}

class CustomTabBar: UITabBar {
    private let customHeight: CGFloat = 90
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height = customHeight
        return size
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var newFrame = self.frame
        newFrame.size.height = customHeight
        newFrame.origin.y = (superview?.frame.height ?? UIScreen.main.bounds.height) - customHeight
        self.frame = newFrame
    }
}
