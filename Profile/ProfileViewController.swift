import UIKit

final class ProfileViewController: UIViewController {
    @IBOutlet private weak var profileImage: UIImageView!
    @IBOutlet private weak var profileUserName: UILabel!
    @IBOutlet private weak var profileAccountName: UILabel!
    @IBOutlet private weak var profileUserStatus: UILabel!

    @IBAction private func didTapLogoutButton(_ sender: Any) {
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel, handler: { _ in

        })
        let okAction = UIAlertAction(title: "Да", style: .default, handler: { _ in

        })
        alert.addAction(okAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    override func viewDidLoad() {
        /* TESTING OUTLETS */
        profileImage.image = UIImage(named: "7")
        profileUserName.text = "Ренат Гареев"
        profileAccountName.text = "@gareevrenat"
        profileUserStatus.text = "Не ошибается тот, кто ничего не делает"
        /* -------------- */
    }
}
