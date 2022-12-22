import UIKit

final class AuthViewController: UIViewController, WebViewViewControllerProtocol {
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let storage: OAuth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var tabBarSeguePerformed: Int = 0
    static let shared = AuthViewController()
    private enum Keys: String {
        case access_token
    }

    @IBAction func didTapLoginButton(_ sender: Any) {
        performSegue(withIdentifier: showWebViewSegueIdentifier, sender: sender)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarSeguePerformed = 0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            let viewController = segue.destination as! WebViewViewController
            viewController.authDelegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) -> Void {
        vc.dismiss(animated: true)
        DispatchQueue.main.async {
            UIBlockingProgressHUD.show()
        }
        let oauth: OAuth2Service = OAuth2Service()
        oauth.fetchAuthToken(code: code, completion: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                UIBlockingProgressHUD.show()
            }
            let alertService: AlertService = AlertService(controller: self)
            switch result {
            case .failure(let error):
                alertService.showAlert(error: error)
            case .success(let oauthTokenResponseBody):
                if !oauthTokenResponseBody.access_token.isEmpty {
                    self.storage.token = oauthTokenResponseBody.access_token
                    self.webViewViewtokenReceived()
                } else {
                    alertService.showAlert(error: ImageFeedError.emptyToken)
                }
            }
        })
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }

    func webViewViewtokenReceived() {
        profileService.fetchProfile(completion: { [weak self] result in
            guard let self = self else { return }
            let alertService: AlertService = AlertService(controller: self)
            switch result {
            case .success:
                UIBlockingProgressHUD.dismiss()
                if let username = self.profileService.profile?.username {
                    self.profileImageService.fetchProfileImageURL(username: username, completion: { result in
                        if case let .failure(error) = result {
                            alertService.showAlert(error: error)
                        }
                    })
                    if self.tabBarSeguePerformed == 0 {
                        self.tabBarSeguePerformed = 1
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: showTabBarViewSegueIdentifier, sender: nil)
                        }
                    }
                }
                else {
                    alertService.showAlert(error: ImageFeedError.emptyUsername)
                }
            case .failure(let error):
                alertService.showAlert(error: error)
            }
        })
    }
}
