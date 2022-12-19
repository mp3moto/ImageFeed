import UIKit

final class SingleImageViewController: UIViewController {
    var image = UIImage() {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }

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
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityController, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        let imageSize = image.size
        let containerSize = scrollView.bounds.size
        var widthRatio, heightRatio, ratio: CGFloat
        view.layoutIfNeeded()

        widthRatio = containerSize.width / imageSize.width
        heightRatio = containerSize.height / imageSize.height

        if widthRatio < heightRatio {
            ratio = widthRatio
        } else {
            ratio = heightRatio
        }

        scrollView.minimumZoomScale = ratio
        if ratio < 1 {
            scrollView.maximumZoomScale = 1.25
        }
        else {
            scrollView.maximumZoomScale = ratio + (ratio * 0.25)
        }

        scrollView.maximumZoomScale = heightRatio + (heightRatio * 0.25)
        scrollView.setZoomScale(heightRatio, animated: false)
        let imageCoords = getImageCenterCoords(imageSize: image.size, containerSize: scrollView.bounds.size, scale: scrollView.zoomScale)

        setImageCoords(coords: imageCoords)
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
        let imageCoords = getImageCoords(imageSize: self.image.size, containerSize: scrollView.bounds.size, scale: scrollView.zoomScale)
        setImageCoords(coords: imageCoords)
    }
}
