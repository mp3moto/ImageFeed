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
    
    var profileImageGradient = CAGradientLayer()
    var profileUserNameGradient = CAGradientLayer()
    var profileAccountNameGradient = CAGradientLayer()
    var profileUserStatusGradient = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageGradient = GradientForView(width: 70, height: 70).getAnimatedLayer()
        profileUserNameGradient = GradientForView(width:223, height: 18).getAnimatedLayer()
        profileAccountNameGradient = GradientForView(width: 89, height: 18).getAnimatedLayer()
        profileUserStatusGradient = GradientForView(width: 67, height: 18).getAnimatedLayer()
        
        profileImage.layer.addSublayer(profileImageGradient)
        profileUserName.layer.addSublayer(profileUserNameGradient)
        profileAccountName.layer.addSublayer(profileAccountNameGradient)
        profileUserStatus.layer.addSublayer(profileUserStatusGradient)
        
        
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
                self.profileImageGradient.removeFromSuperlayer()
            case .failure:
                return
            }
        }
    }

    func updateProfileDetails(profile: Profile) {
        self.profileUserName.text = profile.name()
        self.profileAccountName.text = profile.username
        self.profileUserStatus.text = profile.bio
        
        self.profileUserNameGradient.removeFromSuperlayer()
        self.profileAccountNameGradient.removeFromSuperlayer()
        self.profileUserStatusGradient.removeFromSuperlayer()
    }
}
