import UIKit
import WebKit

final class WebViewViewController: UIViewController{
    weak var authDelegate: WebViewViewControllerProtocol?
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    @IBOutlet private weak var webViewViewController: WKWebView!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBAction func didTapBackButton(_ sender: Any) {
        authDelegate?.webViewViewControllerDidCancel(self)
    }

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
        
        estimatedProgressObservation = webViewViewController.observe(
            \.estimatedProgress,
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 self.updateProgress()
             })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSplashViewSegueIdentifier {
            _ = segue.destination as! SplashViewController
        } else {
            super.prepare(for: segue, sender: sender)
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
            authDelegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        /*print("error occured")
        let nserr = error as NSError
        if nserr.code != 102 {
            print("nserr.code = \(nserr.code)")
            if let error = error as? URLError {
                print("error.code = \(error.code)")
            }
            let alert = AlertService(
                title: "Ошибка",
                message: "Нет соединения с сайтом Unsplash или интернетом",
                buttonText: "ОК",
                controller: self) { _ in
                    self.authDelegate?.webViewViewControllerDidCancel(self)
                }
            alert.show()
        }*/
        
        if let err = error as? URLError {
            var message: String?
            switch(err.code) {
            case .cancelled:
              message = "Сервер разорвал соединение"
            case .cannotFindHost:
                message = "Не удается найти сервер"
            case .notConnectedToInternet:
                message = "Нет соединения с интернетом"
            case .resourceUnavailable:
                message = "Сайт Unsplash недоступен"
            case .timedOut:
                message = "Превышен лимит времени"
            default:
                message = "Неизвестная ошибка с кодом: \(err.code)"
            }
            if let message = message {
                let alert = AlertService(
                    title: "Ошибка",
                    message: "\(message)",
                    buttonText: "ОК",
                    controller: self) { _ in
                        self.authDelegate?.webViewViewControllerDidCancel(self)
                    }
                alert.show()
            } else {
                self.authDelegate?.webViewViewControllerDidCancel(self)
            }
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
