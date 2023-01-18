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

    @IBAction private func setIsLiked(_ sender: UIButton) {
        delegate?.imagesListCellDidTapLike(self)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: cellImage.bounds.width, height: cellImage.bounds.height))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 16
        gradient.masksToBounds = true
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.autoreverses = true
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        
        cellImage.kf.cancelDownloadTask()
        cellDate.text = ""
        cellLike.setImage(UIImage(named: "NoLike"), for: .normal)
        cellImage.image = UIImage(named: "Stub")
    }
}
