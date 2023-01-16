import Foundation

protocol ImagesListServiceProtocol: AnyObject {
    func fetchPhotosNextPage()
    func toggleLike(id: String, isLike: Bool, _ completion: @escaping(Result<Bool, Error>) -> Void)
}
