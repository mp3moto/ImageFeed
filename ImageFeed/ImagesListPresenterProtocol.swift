import UIKit

protocol ImagesListPresenterProtocol: AnyObject {
    func fetchPhotosNextPage()
    func imagesListCellDidTapLike(_ cell: ImagesListCell, indexPath: IndexPath)
    func didLoad()
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath)
    var photosCount: Int { get }
    func photo(index: Int) -> Photo
    func updateTableViewAnimated(tableView: UITableView)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    var photosCount: Int {
        return imagesList.photos.count
    }
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    func didLoad() {
        imagesList.fetchPhotosNextPage()
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        if let thumbURL = URL(string: imagesList.photos[indexPath.row].thumbImageURL) {
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(with: thumbURL, placeholder: UIImage(named: "Stub")) { _ in
                cell.cellImage.contentMode = .scaleAspectFill
            }
        } else {
            cell.cellImage.image = UIImage(named: "Stub")
        }
        let liked: String = imagesList.photos[indexPath.row].isLiked ? "Like" : "NoLike"
        cell.cellLike.setImage(UIImage(named: liked), for: .normal)
        if let createdAt = imagesList.photos[indexPath.row].createdAt {
            cell.cellDate.text = dateFormatter.string(from: createdAt)
        } else {
            cell.cellDate.text = ""
        }
    }
    
    func photo(index: Int) -> Photo {
        return imagesList.photos[index]
    }
    
    func fetchPhotosNextPage() {
        imagesList.fetchPhotosNextPage()
    }
    
    func updateTableViewAnimated(tableView: UITableView) {
        tableView.performBatchUpdates {
            var indexPathArray: [IndexPath] = []
            for index in imagesList.lastPhotosCount..<imagesList.photos.count {
                indexPathArray.append(IndexPath(row: index, section: 0))
            }
            tableView.insertRows(at: indexPathArray, with: .automatic)
            imagesList.lastPhotosCount = imagesList.photos.count
        }
    }
    
    func imagesListCellDidTapLike(_ cell: ImagesListCell, indexPath: IndexPath) {
        let photo = imagesList.photos[indexPath.row]
        imagesList.toggleLike(id: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success(let liked):
                let image: String = liked ? "Like" : "NoLike"
                cell.cellLike.setImage(UIImage(named: image), for: .normal)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    var imagesList: ImagesListService
    
    init(imagesList: ImagesListService) {
        self.imagesList = imagesList
    }
}
