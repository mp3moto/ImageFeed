import Foundation

protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func updateAvatar()
    func updateProfileDetails()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    func viewDidLoad() {
        updateAvatar()
        updateProfileDetails()
    }
    
    func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            return
        }
        view?.updateAvatar(url: url)
    }
    
    func updateProfileDetails() {
        if let profile = profileService.profile {
            view?.updateProfileDetails(profile: profile)
        }
    }
}
