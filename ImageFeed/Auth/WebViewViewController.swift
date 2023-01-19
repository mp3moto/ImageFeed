import UIKit
import WebKit

final class WebViewViewController: UIViewController, WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    weak var authDelegate: WebViewViewControllerDelegateProtocol?
    private var estimatedProgressObservation: NSKeyValueObservation?

    @IBOutlet private weak var webViewViewController: WKWebView!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBAction func didTapBackButton(_ sender: Any) {
        authDelegate?.webViewViewControllerDidCancel(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webViewViewController.navigationDelegate = self
        presenter?.viewDidLoad()

        estimatedProgressObservation = webViewViewController.observe(
            \.estimatedProgress,
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 self.presenter?.didUpdateProgressValue(self.webViewViewController.estimatedProgress)
             }
        )
    }
    
    func load(request: URLRequest) {
        webViewViewController.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            authDelegate?.webViewViewController(self, didAuthenticateWithCode: code)
            
            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                records.forEach { record in
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                }
            }
            
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if let err = error as? URLError {
            let message = err.errorDescription()
            let alert = AlertService(controller: self)
            alert.showCustomAlert(title: "Ошибка", message: message, buttonText: "ОК") { [weak self] _ in
                guard let self = self else { return }
                self.dismiss(animated: true)
            }
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
}
