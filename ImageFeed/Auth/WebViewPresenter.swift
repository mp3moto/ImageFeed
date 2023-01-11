import Foundation

public protocol WebViewPresenterProtocol: AnyObject {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPreseter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    var authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }

    func viewDidLoad() {
        var urlComponents = URLComponents(string: UnsplashAuthorizeURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: AccessScope)
        ]
        let url = urlComponents.url!
        let request = authHelper.authRequest()
        
        didUpdateProgressValue(0)
        
        view?.load(request: request)
    }

    func didUpdateProgressValue(_ newValue: Double) {
        var value: Double
        if newValue < 0 || newValue > 100 {
            if newValue < 0 {
                value = 0
            } else {
                value = 100
            }
        } else {
            value = newValue
        }
        
        view?.setProgressValue(Float(value))
        
        let shouldHideProgress = shouldHideProgress(for: value)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress( for value: Double) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}
