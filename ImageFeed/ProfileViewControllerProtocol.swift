import Foundation

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func updateAvatar(url: URL)
    func updateProfileDetails(profile: Profile)
}
