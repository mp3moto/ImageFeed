import UIKit
import WebKit

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let storage: OAuth2TokenStorage = OAuth2TokenStorage()
    private enum Keys: String {
        case access_token
    }

    @IBAction func didTapLoginButton(_ sender: Any) {
        performSegue(withIdentifier: showWebViewSegueIdentifier, sender: sender)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
        let oauth: OAuth2Service = OAuth2Service()
        oauth.fetchAuthToken(code: code, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let oauthTokenResponseBody):
                if !oauthTokenResponseBody.access_token.isEmpty {
                    self.storage.token = oauthTokenResponseBody.access_token
                    self.webViewViewtokenReceived(vc)
                } else {
                    print("error occured: access_token is empty")
                }
            }
        })
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }

    func webViewViewtokenReceived(_ vc: WebViewViewController) {
        DispatchQueue.main.async {
            vc.performSegue(withIdentifier: showSplashViewSegueIdentifier, sender: nil)
        }
    }
}
