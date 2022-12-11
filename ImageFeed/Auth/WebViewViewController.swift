import UIKit
import WebKit

final class WebViewViewController: UIViewController{
    weak var authDelegate: WebViewViewControllerDelegate?
    @IBOutlet private weak var webViewViewController: WKWebView!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBAction func didTapBackButton(_ sender: Any) {
        authDelegate?.webViewViewControllerDidCancel(self)
    }
    var delay: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        webViewViewController.navigationDelegate = self
        var urlComponents = URLComponents(string: UnsplashAuthorizeURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: AccessScope)
        ]
        let url = urlComponents.url!
        let request = URLRequest(url: url)
        webViewViewController.load(request)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSplashViewSegueIdentifier {
            _ = segue.destination as! SplashViewController
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        webViewViewController.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        webViewViewController.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    private func updateProgress() {
        let progress: Float = Float(webViewViewController.estimatedProgress)
        progressView.progress = progress
        progressView.isHidden = abs(progress - 1.0) <= 0.0001
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            authDelegate?.webViewViewController(self, didAuthenticateWithCode: code, delay: delay)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
