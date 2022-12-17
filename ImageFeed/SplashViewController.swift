import UIKit

final class SplashViewController: UIViewController, SplashViewControllerProtocol {
    private let showTabBarViewSegueIdentifier = "ShowTabBarView"
    private let storage: OAuth2TokenStorage = OAuth2TokenStorage()
    private let networkClient: NetworkRouting = NetworkClient()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentsURL) 
        
        profileService.delegate = self
        DispatchQueue.main.async {
            UIBlockingProgressHUD.show()
        }
        //let profileService: ProfileService = ProfileService()
        //print("0. profileService.fetchProfile")
        
        profileService.fetchProfile(completion: { result in
            switch result {
            case .success(_):
                //print("1. profileService.fetchProfile -> success")
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    if let username = self.profileService.profile?.username {
                        self.profileImageService.fetchProfileImageURL(username: username, completion: { result in
                            switch result {
                            case .success(_):
                                break
                                //print("2. profileImageService.fetchProfile -> success")
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        })
                        self.performSegue(withIdentifier: self.showTabBarViewSegueIdentifier, sender: nil)
                    } else {
                        print("no username")
                    }
                }
            case .failure(let error):
                //print("Failure catched")
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    if error as! ProfileServiceError == ProfileServiceError.emptyToken {
                        self.performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
                    } else {
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
}
