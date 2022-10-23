import UIKit

final class SingleImageViewController: UIViewController {
    var image = UIImage()
    @IBOutlet var imageView: UIImageView!
    
    @IBAction private func didTabBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
    }
}
