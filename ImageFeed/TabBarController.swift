import UIKit

final class TabBarController: UITabBarController {
    private let splash = SplashViewController.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        //splash.destroyView()
    }
}
