import UIKit
import Kingfisher

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?
    
    @IBOutlet private weak var profileUserName: UILabel!
    @IBOutlet private weak var profileAccountName: UILabel!
    @IBOutlet private weak var profileUserStatus: UILabel!
    @IBOutlet weak var profileImage: UIImageView!

    @IBAction func didTapLogoutButton(_ sender: Any) {
        let alert = AlertService(controller: self)
        alert.showLogoutAlert()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let presenter = ProfileViewPresenter()
        presenter.view = self
        presenter.viewDidLoad()

        NotificationCenter.default.addObserver(
            forName: ProfileImageService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.presenter?.updateAvatar()
        }
        presenter.updateAvatar()
        presenter.updateProfileDetails()
    }

    
    func updateAvatar(url: URL) {
        profileImage.kf.setImage(with: url, placeholder: UIImage(named: "avatar"))
    }

    func updateProfileDetails(profile: Profile) {
        self.profileUserName.text = profile.name()
        self.profileAccountName.text = profile.username
        self.profileUserStatus.text = profile.bio
    }
}
