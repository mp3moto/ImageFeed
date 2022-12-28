import UIKit
import Kingfisher

class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    @IBOutlet private var tableView: UITableView!
    private let imagesList: ImagesListService = ImagesListService()

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    private var imagesListServiceObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        imagesList.fetchPhotosNextPage()

        NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateTableViewAnimated()
        }
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
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagesList.photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        configCell(for: imageListCell, with: indexPath)
        imageListCell.delegate = self
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == imagesList.photos.count {
            imagesList.fetchPhotosNextPage()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            viewController.photo = imagesList.photos[indexPath.row]
        }
        else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func updateTableViewAnimated() {
        tableView.performBatchUpdates {
            var indexPathArray: [IndexPath] = []
            for index in imagesList.lastPhotosCount..<imagesList.photos.count {
                indexPathArray.append(IndexPath(row: index, section: 0))
            }
            self.tableView.insertRows(at: indexPathArray, with: .automatic)
            imagesList.lastPhotosCount = imagesList.photos.count
        }
    }
}

extension ImagesListViewController: UITableViewDelegate, imagesListCellDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        UIBlockingProgressHUD.show()
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
        UIBlockingProgressHUD.dismiss()
    }
}
