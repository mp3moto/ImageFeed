import UIKit

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
}

final class ImagesListServiceMock: ImagesListServiceProtocol {
    private (set) var photos: [Photo] = []
    var lastPhotosCount: Int = 0
    func fetchPhotosNextPage() {
        for idx in 1...5 {
            photos.append(Photo(id: "\(idx)", size: CGSize(width: 300, height: 300), createdAt: nil, welcomeDescription: nil, thumbImageURL: "https://localhost", fullImageURL: "https://localhost", isLiked: false))
        }
    }
    
    func toggleLike(id: String, isLike: Bool, _ completion: @escaping (Result<Bool, Error>) -> Void) {
        for index in 0..<photos.count {
            if photos[index].id == id {
                photos[index] = Photo(id: "\(photos[index].id)", size: CGSize(width: 300, height: 300), createdAt: nil, welcomeDescription: nil, thumbImageURL: "https://localhost", fullImageURL: "https://localhost", isLiked: !isLike)
                completion(.success(!isLike))
            }
        }
    }
}

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol?
    
    func viewDidLoad() {
        
    }
    
    func updateAvatar() {
        
    }
    
    func updateProfileDetails() {
        let profile = Profile(id: "123", username: "user001", first_name: "Renat", last_name: "Gareev", bio: nil)
        view?.updateProfileDetails(profile: profile)
    }
    
    
}

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    let imagesList = ImagesListServiceMock()
    var viewDidLoadCalled: Bool = false
    func fetchPhotosNextPage() {
        imagesList.fetchPhotosNextPage()
    }
    
    func imagesListCellDidTapLike(_ cell: ImagesListCell, indexPath: IndexPath) {
        imagesList.toggleLike(id: photo(index: 0).id, isLike: !imagesList.photos[0].isLiked) { _ in }
    }
    
    func didLoad() {
        viewDidLoadCalled = true
        imagesList.fetchPhotosNextPage()
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
    }
    
    var photosCount: Int {
        return imagesList.photos.count
    }
    
    func photo(index: Int) -> Photo {
        return imagesList.photos[index]
    }
    
    func updateTableViewAnimated(tableView: UITableView) {
        
    }
    
    func toggleLike(index: Int) {
        imagesList.toggleLike(id: imagesList.photos[index].id, isLike: imagesList.photos[index].isLiked) { _ in }
    }
    
 }

    
    
    

