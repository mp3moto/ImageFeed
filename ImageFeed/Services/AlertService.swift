import UIKit

class AlertService {
    /*
    private let title: String
    private let message: String
    private let buttonText: String
    */
    private let controller: UIViewController
    /*
    private let actionHandler: ((UIAlertAction) -> Void)?
    */
    init(
        /*title: String,
        message: String,
        buttonText: String,*/
        controller: UIViewController
        /*
        actionHandler: ((UIAlertAction) -> Void)?
        */
    ) {
        /*self.title = title
        self.message = message
        self.buttonText = buttonText*/
        self.controller = controller
        //self.actionHandler = actionHandler
    }
    
    func showAlert(error: Error) {
        
    }
    /*
    func show(_ id: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let id = id {
            alert.view.accessibilityIdentifier = id
        }
        let action = UIAlertAction(
            title: self.buttonText,
            style: .default,
            handler: { action in
                self.actionHandler?(action)
            })

        alert.addAction(action)
        DispatchQueue.main.async {
            self.controller.present(alert, animated: true, completion: nil)
        }
    }
     */
}
