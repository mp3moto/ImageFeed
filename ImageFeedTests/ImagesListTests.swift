@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {
    func test10PhotosOn2Page() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController
        else { return }
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        
        // when
        _ = viewController.view
        viewController.presenter?.fetchPhotosNextPage()
        
        // then
        XCTAssertEqual(viewController.presenter?.photosCount, 10)
    }
    
    func testLikeFunction() {
        let presenter = ImagesListPresenterSpy()
        
        // when
        presenter.didLoad()
        presenter.toggleLike(index: 0)
        
        // then
        XCTAssertTrue(presenter.photo(index: 0).isLiked)
    }
    
    func testDislikeFunction() {
        let presenter = ImagesListPresenterSpy()
        
        // when
        presenter.didLoad()
        presenter.toggleLike(index: 0)
        presenter.toggleLike(index: 0)
        
        // then
        XCTAssertFalse(presenter.photo(index: 0).isLiked)
    }
}
