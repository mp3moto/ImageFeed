import UIKit
import Kingfisher

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?
    
    @IBOutlet private weak var profileUserName: UILabel!
    @IBOutlet weak var profileAccountName: UILabel!
    @IBOutlet private weak var profileUserStatus: UILabel!
    @IBOutlet weak var profileImage: UIImageView!

    @IBAction func didTapLogoutButton(_ sender: Any) {
        let alert = AlertService(controller: self)
        alert.showLogoutAlert()
    }
    
    private let gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: 70, height: 70))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 35
        gradient.masksToBounds = true

        return gradient
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.addSublayer(gradient)
        profileUserName.layer.addSublayer(gradient)
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.autoreverses = true
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        
        if presenter == nil {
            presenter = ProfileViewPresenter()
        }
        presenter?.view = self
        presenter?.viewDidLoad()

        NotificationCenter.default.addObserver(
            forName: ProfileImageService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.presenter?.updateAvatar()
        }
        presenter?.updateAvatar()
        presenter?.updateProfileDetails()
    }

    
    func updateAvatar(url: URL) {
        profileImage.kf.setImage(with: url, placeholder: UIImage(named: "avatar")) { result in
            switch result {
            case .success:
                self.gradient.removeFromSuperlayer()
            case .failure:
                return
            }
        }
    }

    func updateProfileDetails(profile: Profile) {
        self.profileUserName.text = profile.name()
        self.profileAccountName.text = profile.username
        self.profileUserStatus.text = profile.bio
    }
}
