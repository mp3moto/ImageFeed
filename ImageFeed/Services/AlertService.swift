import UIKit

class AlertService {
    private let controller: UIViewController

    init(controller: UIViewController) {
        self.controller = controller
    }

    func showAlert(error: Error) {
        DispatchQueue.main.async {
            UIBlockingProgressHUD.dismiss()
        }
        let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(
            title: "OK",
            style: .default,
            handler: { action in })

        alert.addAction(action)
        DispatchQueue.main.async {
            self.controller.present(alert, animated: true, completion: nil)
        }
    }

    func showCustomAlert(title: String, message: String, buttonText: String, actionHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(
            title: buttonText,
            style: .default,
            handler: { action in
                actionHandler?(action)
            })

        alert.addAction(action)
        DispatchQueue.main.async {
            self.controller.present(alert, animated: true, completion: nil)
        }
    }
}
