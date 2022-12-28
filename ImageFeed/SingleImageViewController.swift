import UIKit
import Kingfisher
import ProgressHUD

final class SingleImageViewController: UIViewController {
    var photo: Photo?

    struct OptionalCoordinates {
        let x: CGFloat?
        let y: CGFloat?

        init(x: CGFloat?, y: CGFloat?) {
            self.x = x
            self.y = y
        }

        init(x: CGFloat?) {
            self.x = x
            self.y = nil
        }
    }

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBAction private func didTabBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapShareButton(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
        present(activityController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let photo = photo,
              let imageURL = URL(string: photo.fullImageURL)
        else { return }

        let containerSize = scrollView.bounds.size
        /*
         Жаль, что заставляют использовать ProgressHUD. Индикатор от KF смотрится изящнее и не закрывает логотип
         imageView.kf.indicatorType = .activity
        */
        ProgressHUD.show()
        if let indicator = imageView.image {
            let imageSize = indicator.size
            let imageCoords = self.getImageCenterCoords(imageSize: imageSize, containerSize: containerSize, scale: 1.0)
            setImageCoords(coords: imageCoords)
        }

        imageView.kf.setImage(with: imageURL, placeholder: UIImage(named: "Stub")) { _ in
            ProgressHUD.dismiss()
            let imageSize = photo.size
            var widthRatio, heightRatio, ratio: CGFloat
            self.view.layoutIfNeeded()

            widthRatio = containerSize.width / imageSize.width
            heightRatio = containerSize.height / imageSize.height

            if widthRatio < heightRatio {
                ratio = widthRatio
            } else {
                ratio = heightRatio
            }

            self.scrollView.minimumZoomScale = ratio
            if ratio < 1 {
                self.scrollView.maximumZoomScale = 1.25
            }
            else {
                self.scrollView.maximumZoomScale = ratio + (ratio * 0.25)
            }

            self.scrollView.maximumZoomScale = heightRatio + (heightRatio * 0.25)
            self.scrollView.setZoomScale(heightRatio, animated: false)
            
            let imageCoords = self.getImageCenterCoords(imageSize: imageSize, containerSize: self.scrollView.bounds.size, scale: self.scrollView.zoomScale)
            self.setImageCoords(coords: imageCoords)
        }
    }

    private func getImageCoords(imageSize: CGSize, containerSize: CGSize, scale: CGFloat = 1.0) -> OptionalCoordinates {
        let newImageWidth = imageSize.width * scale
        let newImageHeight = imageSize.height * scale
        var x, y: CGFloat?
        if (newImageWidth < containerSize.width) {
            x = -1 * ((containerSize.width - newImageWidth) / 2)
        }
        if (newImageHeight < containerSize.height) {
            y = -1 * ((containerSize.height - newImageHeight) / 2)
        }
        return OptionalCoordinates(x: x, y: y)
    }

    private func getImageCenterCoords(imageSize: CGSize, containerSize: CGSize, scale: CGFloat = 1.0) -> OptionalCoordinates {
        let newImageWidth = imageSize.width * scale
        var x: CGFloat?
        if (newImageWidth < containerSize.width) {
            x = -1 * ((containerSize.width - newImageWidth) / 2)
        }
        else {
            x = 1 * ((newImageWidth / 2) - (containerSize.width / 2))
        }
        return OptionalCoordinates(x: x)
    }

    private func setImageCoords(coords: OptionalCoordinates) {
        if let x = coords.x {
            scrollView.contentOffset.x = x
        }
        if let y = coords.y {
            scrollView.contentOffset.y = y
        }
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let imageSize = CGSize(width: imageView.bounds.width, height: imageView.bounds.height)
        let imageCoords = getImageCoords(imageSize: imageSize, containerSize: scrollView.bounds.size, scale: scrollView.zoomScale)
        setImageCoords(coords: imageCoords)
    }
}
