import UIKit

final class SingleImageViewController: UIViewController {
    var image = UIImage() {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
            // rescaleScrollViewForPerfectView(image: image)
        }
    }
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBAction private func didTabBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.2
        scrollView.maximumZoomScale = 5.0
        imageView.image = image
        let imageSize = image.size
        scrollView.layoutIfNeeded()
        print("viewDidLoad calling getCenterCoordsForImage")
        let imageCoords = getCenterCoordsForImage(imageSize: imageSize, containerSize: scrollView.bounds.size)
        //print("imageCoords = \(imageCoords)")
        scrollView.setContentOffset(imageCoords, animated: true)
        //print("contentOffset = \(scrollView.contentOffset)")
    }
    
    private func getCenterCoordsForImage(imageSize: CGSize, containerSize: CGSize, scale: CGFloat = 1.0) -> CGPoint {
        var newImageWidth = imageSize.width * scale
        var newImageHeight = imageSize.height * scale
        var x, y: CGFloat
        y = 0.0
        print("newImageWidth = \(newImageWidth), newImageHeight = \(newImageHeight), scale = \(scale)")
        if (newImageHeight < containerSize.height) {
            y = -1 * ((containerSize.height - newImageHeight) / 2)
        }
        /*if newImageWidth < containerSize.width && newImageHeight < containerSize.height {
            if newImageWidth < containerSize.width {
                x = -1 * ((containerSize.width - newImageWidth) / 2)
            } else {
                x = 0.0
            }
            if newImageHeight < containerSize.height {
                y = -1 * ((containerSize.height - newImageHeight) / 2)
            } else {
                y = 0.0
            }
        }
        else {
            var hScale = 1.0, wScale = 1.0
            if newImageWidth > containerSize.width {
                wScale = containerSize.width / newImageWidth
            } else {
                wScale = 1.0
            }
            if newImageHeight > containerSize.height {
                hScale = containerSize.height / newImageHeight
            } else {
                hScale = 1.0
            }
            let resultScale = min(wScale, hScale)
            print("resultScale = \(resultScale)")
            newImageWidth = imageSize.width * resultScale
            newImageHeight = imageSize.height * resultScale
            print("containerSize = \(containerSize)")
            print("newImageWidth = \(newImageWidth)")
            print("newImageHeight = \(newImageHeight)")
            if containerSize.width < newImageWidth {
                x = 0.0
                print("x = \(x)")
            } else {
                x = -1 * ((containerSize.width - newImageWidth) / 2)
                
            }
            if newImageHeight < containerSize.height {
                y = -1 * ((containerSize.height - newImageHeight) / 2)
            } else {
                y = 0.0
            }
        }*/
        return CGPoint(x: 0, y: y)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollView.layoutIfNeeded()
        //scrollView.setContentOffset(getCenterCoordsForImage(imageSize: self.image.size, containerSize: scrollView.bounds.size), animated: false)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.layoutIfNeeded()
        print("scrollViewDidEndZooming calling getCenterCoordsForImage")
        let imageCoords = getCenterCoordsForImage(imageSize: self.image.size, containerSize: scrollView.bounds.size, scale: scale)
        //print("imageCoords = \(imageCoords)")
        scrollView.setContentOffset(imageCoords, animated: true)
        
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        //print("didEndScrollingAnimation calling getCenterCoordsForImage")
        //let imageCoords = getCenterCoordsForImage(imageSize: self.image.size, containerSize: scrollView.bounds.size)
        //print("imageCoords = \(imageCoords)")
        //scrollView.setContentOffset(imageCoords, animated: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //scrollView.layoutIfNeeded()
        let imageCoords = getCenterCoordsForImage(imageSize: self.image.size, containerSize: scrollView.bounds.size, scale: scrollView.zoomScale)
        //print("imageCoords = \(imageCoords)")
        scrollView.setContentOffset(imageCoords, animated: false)
        //scrollView.setContentOffset(getCenterCoordsForImage(image: image, containerSize: scrollView.bounds.size), animated: false)
        //print("did scroll")
        //print("scrollView.contentOffset = \(scrollView.contentOffset)")
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        print("scrollViewDidScrollToTop")
        //scrollView.setContentOffset(getCenterCoordsForImage(image: image, containerSize: scrollView.bounds.size), animated: false)
    }
    
}
