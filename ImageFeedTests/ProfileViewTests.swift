@testable import ImageFeed
import XCTest


final class ProfileViewTests: XCTestCase {
    func testProfileInfo() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController
        else { return }
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        
        // when
        _ = viewController.view
        presenter.updateProfileDetails()
        
        // then
        XCTAssertEqual(viewController.profileAccountName.text, "user001")
    }
}
