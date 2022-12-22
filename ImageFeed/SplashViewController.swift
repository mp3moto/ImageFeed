import UIKit

final class SplashViewController: UIViewController {
    private let storage: OAuth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        // Use row below to erase Auth token on app launch for debugging needs. Don't forget to comment it on next launch.
        //storage.token = nil
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        if let _ = self.storage.token {
            profileService.fetchProfile(completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    if let username = self.profileService.profile?.username {
                        self.profileImageService.fetchProfileImageURL(username: username, completion: ({ result in }))
                        self.showImageFeed()
                    }
                    else {
                        self.showAuthScreen()
                    }
                case .failure:
                    let alert = AlertService(controller: self)
                    alert.showCustomAlert(title: "Что-то пошло не так", message: "Не удалось войти в систему", buttonText: "OK") { [weak self] _ in
                        self?.showAuthScreen()
                    }
                }
            })
        } else {
            self.showAuthScreen()
        }
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
            self.performSegue(withIdentifier: showTabBarViewSegueIdentifier, sender: nil)
        }
    }

    func showAuthScreen() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
        }
    }
}
