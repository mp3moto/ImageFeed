import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    static let shared = ProfileViewController()

    @IBOutlet private weak var profileUserName: UILabel!
    @IBOutlet private weak var profileAccountName: UILabel!
    @IBOutlet weak var profileUserStatus: UILabel!
    @IBOutlet private weak var profileImage: UIImageView!

    @IBAction func didTapLogoutButton(_ sender: Any) {
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel, handler: { _ in

        })
        let okAction = UIAlertAction(title: "Да", style: .default, handler: { _ in

        })
        alert.addAction(okAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    private var profileImageServiceObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
        updateAvatar()
        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        }
    }

    func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }

        profileImage.kf.setImage(with: url, placeholder: UIImage(named: "avatar"))
    }

    private func updateProfileDetails(profile: Profile) {
        self.profileUserName.text = profile.name()
        self.profileAccountName.text = profile.username
        self.profileUserStatus.text = profile.bio
    }
}
