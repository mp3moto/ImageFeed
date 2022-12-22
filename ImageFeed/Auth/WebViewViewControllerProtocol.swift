import WebKit

protocol WebViewViewControllerProtocol: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) -> Void
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) -> Void
}
