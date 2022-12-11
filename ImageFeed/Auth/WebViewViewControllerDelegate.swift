import Foundation
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String, delay: Int) -> Void
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) -> Void
    func webViewViewtokenReceived(_ vc: WebViewViewController) -> Void
}
