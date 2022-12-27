import Foundation

final class ImagesListService {
    private let storage: OAuth2TokenStorage = OAuth2TokenStorage()
    private (set) var photos: [Photo] = []
    private var nextPage: Int?
    var lastPhotosCount: Int = 0
    private var task, likeTask: URLSessionTask?
    
    //static let shared = ImagesListService()
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private func getNextPage() -> Int {
        if let nextPage = nextPage {
            return nextPage
        } else {
            return 1
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
    
    func fetchPhotosNextPage() {
        if let _ = task {
            return
        } else {
            guard let request = makePhotosRequest() else { return }
            print(request)
            let session = URLSession.shared
            let task = session.objectTask(for: request) { (result: Result<[PhotoResult], Error>) in
                self.task = nil
                switch result {
                case .success(let photoResults):
                    if let nextPage = self.nextPage {
                        self.nextPage = nextPage + 1
                    } else {
                        self.nextPage = 2
                    }

                    DispatchQueue.main.async {
                        for photo in photoResults {
                            let size = CGSize(width: Double(photo.width), height: Double(photo.height))
                            let date: Date?
                            
                            if let tmp = photo.created_at {
                                let dateFormatter = ISO8601DateFormatter()
                                date = dateFormatter.date(from: tmp)!
                            } else {
                                date = nil
                            }
                            
                            let welcomeDescription: String?
                            if let tmp = photo.description {
                                welcomeDescription = tmp
                            } else {
                                welcomeDescription = nil
                            }
                            
                            let largeImageURL: String?
                            if let tmp = photo.urls.regular {
                                largeImageURL = tmp
                            } else {
                                largeImageURL = nil
                            }
                            
                            self.photos.append(Photo(id: photo.id, size: size, createdAt: date, welcomeDescription: welcomeDescription, thumbImageURL: photo.urls.small, largeImageURL: largeImageURL, isLiked: photo.liked_by_user))
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
            print(request)
            let session = URLSession.shared
            let task = session.objectTask(for: request) { (result: Result<LikeResult, Error>) in
                self.likeTask = nil
                switch result {
                case .success(let likeResult):
                    //print("toggleLike result is")
                   // print(photoResult)
                    DispatchQueue.main.async {
                        if let index = self.photos.firstIndex(where: { $0.id == id }) {
                            //let photo = self.photos[index]
                            let date: Date?
                            if let tmp = likeResult.photo.created_at {
                                let dateFormatter = ISO8601DateFormatter()
                                date = dateFormatter.date(from: tmp)!
                            } else {
                                date = nil
                            }
                            let newPhoto = Photo(
                                id: likeResult.photo.id,
                                size: CGSize(width: likeResult.photo.width, height: likeResult.photo.height),
                                createdAt: date,
                                welcomeDescription: likeResult.photo.description,
                                thumbImageURL: likeResult.photo.urls.small,
                                largeImageURL: likeResult.photo.urls.regular,
                                isLiked: likeResult.photo.liked_by_user
                            )
                            self.photos[index] = newPhoto
                            completion(.success(newPhoto.isLiked))
                        }
                    }
                    return
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            self.likeTask = task
            task.resume()
        }
    }
    
}
