import UIKit

final class SplashViewController: UIViewController {
    private let showTabBarViewSegueIdentifier = "ShowTabBarView"
    private let storage: OAuth2TokenStorage = OAuth2TokenStorage()
    private let networkClient: NetworkRouting = NetworkClient()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        /*DispatchQueue.main.async {
            UIBlockingProgressHUD.show()
        }*/
        let profileService: ProfileService = ProfileService()
        profileService.getProfile(completion: { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    self.performSegue(withIdentifier: self.showTabBarViewSegueIdentifier, sender: nil)
                }
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    self.performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
                }
            }
        })
        
        
        //
        //progress.show()
        /*if let token = storage.token {
            DispatchQueue.main.async {
                UIBlockingProgressHUD.show()
            }
            loadUserData(token: token, completion: { result in
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let unsplashProfileData):
                    if let _ = unsplashProfileData.id {
                        //print(unsplashProfileData)
                        DispatchQueue.main.async {
                            //ProgressHUD.dismiss()
                            UIBlockingProgressHUD.dismiss()
                            self.performSegue(withIdentifier: self.showTabBarViewSegueIdentifier, sender: nil)
                        }
                    } else {
                        print("error occured: wrong data")
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
                        }
                    }
                }
            })
        } else {
            performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
        }*/
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
}
