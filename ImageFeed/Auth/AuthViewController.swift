import UIKit
import WebKit

final class AuthViewController: UIViewController, WebViewViewControllerProtocol {
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let storage: OAuth2TokenStorage = OAuth2TokenStorage()
    //private
    private enum Keys: String {
        case access_token
    }

    @IBAction func didTapLoginButton(_ sender: Any) {
        performSegue(withIdentifier: showWebViewSegueIdentifier, sender: sender)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //splash.destroyView()
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
        let oauth: OAuth2Service = OAuth2Service()
        oauth.fetchAuthToken(code: code, completion: { [weak self] result in
            guard let self = self else { return }
            let alertService: AlertService = AlertService(controller: self)
            switch result {
            case .failure:
                alertService.showAlert(error: ProfileServiceError.invalidToken)
                /*let alert = AlertService(
                    title: "Ошибка",
                    message: "Не удается получить токен авторизации",
                    buttonText: "ОК",
                    controller: self) { [weak self] _ in
                        self?.performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
                    }
                alert.show()*/
            case .success(let oauthTokenResponseBody):
                if !oauthTokenResponseBody.access_token.isEmpty {
                    self.storage.token = oauthTokenResponseBody.access_token
                    self.webViewViewtokenReceived(/*vc*/)
                } else {
                    alertService.showAlert(error: ProfileServiceError.emptyToken)
                    //print("error occured: access_token is empty")
                }
            }
        })
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }

    func webViewViewtokenReceived(/*_ vc: WebViewViewController*/) {
        let profileService: ProfileService = ProfileService()
        DispatchQueue.main.async {
            UIBlockingProgressHUD.show()
            profileService.fetchProfile(completion: { [weak self] result in
                guard let self = self else { return }
                let alertService: AlertService = AlertService(controller: self)
                switch result {
                case .success:
                    UIBlockingProgressHUD.dismiss()
                    if let username = profileService.profile?.username {
                        let profileImage: ProfileImageService = ProfileImageService()
                        profileImage.fetchProfileImageURL(username: username, completion: { result in
                            if case let .failure(error) = result {
                                alertService.showAlert(error: error)
                            }
                        })
                        self.performSegue(withIdentifier: showTabBarViewSegueIdentifier, sender: nil)
                    }
                    else {
                        alertService.showAlert(error: ProfileServiceError.emptyUsername)
                    }
                case .failure(let error):
                    alertService.showAlert(error: error)
                }
            })
        }
    }
}
