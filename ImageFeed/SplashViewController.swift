import UIKit
import SwiftKeychainWrapper

final class SplashViewController: UIViewController, SplashViewControllerProtocol, KeychainEventsProtocol {
    private let showTabBarViewSegueIdentifier = "ShowTabBarView"
    private let storage: OAuth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    static let shared = SplashViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        DispatchQueue.main.async {
            UIBlockingProgressHUD.show()
        }

        profileService.fetchProfile(completion: { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    if let username = self.profileService.profile?.username {
                        self.profileImageService.fetchProfileImageURL(username: username, completion: { result in
                            switch result {
                            case .success(_):
                                break
                            case .failure(let error):
                                let alert = AlertService(
                                    title: "Ошибка",
                                    message: error.localizedDescription,
                                    buttonText: "ОК",
                                    controller: self) { _ in }
                                alert.show()
                            }
                        })
                        self.performSegue(withIdentifier: self.showTabBarViewSegueIdentifier, sender: nil)
                    } else {
                        let alert = AlertService(
                            title: "Ошибка",
                            message: "Не удалось получить имя профиля Unsplash",
                            buttonText: "ОК",
                            controller: self) { _ in
                                self.performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
                            }
                        alert.show()
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    if error as! ProfileServiceError == ProfileServiceError.emptyToken {
                        self.performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
                    } else {
                        KeychainWrapper.standard.removeObject(forKey: "Auth token")
                        let alert = AlertService(
                            title: "Что-то пошло не так (",
                            message: "Не удалось войти в систему\n\(error.localizedDescription)",
                            buttonText: "OK",
                            controller: self) { _ in
                                self.performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
                            }
                        alert.show()
                    }
                }
            }
        })
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

    func showImageFeed() {
        DispatchQueue.main.async {
            UIBlockingProgressHUD.dismiss()
            self.performSegue(withIdentifier: self.showTabBarViewSegueIdentifier, sender: nil)
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
