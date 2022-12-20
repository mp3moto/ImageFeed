import UIKit

final class SplashViewController: UIViewController, SplashViewControllerProtocol, KeychainEventsProtocol {
    //private let showTabBarViewSegueIdentifier = "ShowTabBarView"
    private let storage: OAuth2TokenStorage = OAuth2TokenStorage()
    //private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    static let shared = SplashViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //storage.token = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //UIBlockingProgressHUD.show()

        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case showAuthViewSegueIdentifier:
            _ = segue.destination as! AuthViewController
        case showTabBarViewSegueIdentifier:
            _ = segue.destination as! TabBarController
        default:
            super.prepare(for: segue, sender: sender)
        }
    }
    
    /*func destroyView() {
        DispatchQueue.main.async {
            self.dismiss(animated: false)
        }
        
    }*/

    func showImageFeed() {
        DispatchQueue.main.async {
            UIBlockingProgressHUD.dismiss()
            self.performSegue(withIdentifier: self.showTabBarViewSegueIdentifier, sender: nil)
            //self.dismiss(animated: false)
        }
    }

    func keychainError() {
        let alert = AlertService(
            title: "Ошибка",
            message: "Не удается получить доступ к защищенному хранилищу",
            buttonText: "ОК",
            controller: self) { _ in
                self.performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
            }
        alert.show()
    }
}
