import UIKit

protocol imagesListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellDate: UILabel!
    @IBOutlet weak var cellLike: UIButton!
    weak var delegate: imagesListCellDelegate?
    static let reuseIdentifier = "ImagesListCell"

    @IBAction func setIsLiked(_ sender: UIButton) {
        delegate?.imagesListCellDidTapLike(self)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }
}
