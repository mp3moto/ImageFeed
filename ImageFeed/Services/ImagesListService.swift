import Foundation

final class ImagesListService {
    private let storage: OAuth2TokenStorage = OAuth2TokenStorage()
    private (set) var photos: [Photo] = []
    private var nextPage: Int?
    var lastPhotosCount: Int = 0
    private var task, likeTask: URLSessionTask?
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private func getNextPage() -> Int {
        if let nextPage = nextPage {
            return nextPage
        } else {
            return 1
        }
    }
    
    private func setNextPage() {
        if let nextPage = self.nextPage {
            self.nextPage = nextPage + 1
        } else {
            self.nextPage = 2
        }
    }
    
    private func getPhotosDataURLQueryItems() -> [String: Any] {
        let page = getNextPage()
        let per_page = 5
        let natural = page > 1 ? true : false
        switch natural {
        case true:
            return ["page": page, "per_page": per_page]
        case false:
            return ["per_page": per_page]
        }
    }
    
    private func makePhotosRequest() -> URLRequest? {
        if let token = storage.token {
            let req: RequestFactoryProtocol = RequestFactory()
            guard let request = req.createRequest(
                url: PhotosDataURL!,
                method: "GET",
                postData: getPhotosDataURLQueryItems(),
                headers: ["Authorization": "Bearer \(token)"],
                queryItemsInURL: false
            ) else { return nil }
            return request
        } else {
            return nil
        }
    }
    
    private func makeLikeRequest(id: String, isLike: Bool) -> URLRequest? {
        if let token = storage.token {
            let req: RequestFactoryProtocol = RequestFactory()
            guard let likeURL = URL(string: "\(API)/photos/\(id)/like"),
                  let request = req.createRequest(
                url: likeURL,
                method: isLike ? "POST" : "DELETE",
                postData: nil,
                headers: ["Authorization": "Bearer \(token)"],
                queryItemsInURL: false
            ) else { return nil }
            return request
        } else {
            return nil
        }
    }
    
    func convert(photo: PhotoResult) -> Photo? {
        guard let id = photo.id,
              let width = photo.width,
              width > 0,
              let height = photo.height,
              height > 0,
              let urls = photo.urls,
              let thumbImageURL = urls.small,
              let _ = URL(string: thumbImageURL),
              let largeImageURL = urls.regular,
              let _ = URL(string: largeImageURL),
              let fullImageURL = urls.full,
              let _ = URL(string: fullImageURL)
        else { return nil }
        
        let createdAt: Date?
        if let tmp = photo.created_at {
            let dateFormatter = ISO8601DateFormatter()
            createdAt = dateFormatter.date(from: tmp)
        } else {
            createdAt = nil
        }
        
        let isLiked: Bool
        if let liked = photo.liked_by_user {
            isLiked = liked ? true : false
        } else {
            isLiked = false
        }
        
        let welcomeDescription: String?
        if let tmp = photo.description {
            welcomeDescription = tmp
        } else {
            welcomeDescription = nil
        }
        
        return Photo(
            id: id,
            size: CGSize(width: width, height: height),
            createdAt: createdAt,
            welcomeDescription: welcomeDescription,
            thumbImageURL: thumbImageURL,
            largeImageURL: largeImageURL,
            fullImageURL: fullImageURL,
            isLiked: isLiked
        )
    }
    
    func fetchPhotosNextPage() {
        if let _ = task {
            return
        } else {
            guard let request = makePhotosRequest() else { return }
            //print(request)
            let session = URLSession.shared
            let task = session.objectTask(for: request) { (result: Result<[PhotoResult], Error>) in
                self.task = nil
                switch result {
                case .success(let photoResults):
                    self.setNextPage()
                    DispatchQueue.main.async {
                        for photo in photoResults {
                            if let newPhoto = self.convert(photo: photo) {
                                self.photos.append(newPhoto)
                            }
                        }

                        NotificationCenter.default.post(
                            name: ImagesListService.DidChangeNotification,
                            object: self,
                            userInfo: ["photos": self.photos]
                        )
                     }
                case .failure:
                    return
                }
            }
            self.task = task
            task.resume()
        }
    }
    
    func toggleLike(id: String, isLike: Bool, _ completion: @escaping(Result<Bool, Error>) -> Void) {
        if let _ = likeTask {
            return
        } else {
            guard let request = makeLikeRequest(id: id, isLike: isLike) else { return }
            //print(request)
            let session = URLSession.shared
            let task = session.objectTask(for: request) { (result: Result<LikeResult, Error>) in
                self.likeTask = nil
                switch result {
                case .success(let likeResult):
                    DispatchQueue.main.async {
                        if let index = self.photos.firstIndex(where: { $0.id == id }) {
                            if let newPhoto = self.convert(photo: likeResult.photo) {
                                self.photos[index] = newPhoto
                                completion(.success(newPhoto.isLiked))
                            }
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            self.likeTask = task
            task.resume()
        }
    }
    
}
