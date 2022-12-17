import Foundation

protocol RequestFactoryProtocol {
    func createRequest(url: URL, method: String, postData: [String: Any]?, headers: [String: Any]?, queryItemsInURL: Bool) -> URLRequest?
}
