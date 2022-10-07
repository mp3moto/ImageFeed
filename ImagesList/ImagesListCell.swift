import UIKit

final class ImagesListCell: UITableViewCell {
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellDate: UILabel!
    @IBOutlet weak var cellLike: UIButton!
    static let reuseIdentifier = "ImagesListCell"
}

