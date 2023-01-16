@testable import ImageFeed
import XCTest

final class WebViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as? WebViewViewController
        else { return }
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterCallsLoadRequest() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as? WebViewViewControllerSpy
        else { return }
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        // given
        let authHelper = AuthHelper()
        let presenter = WebViewPreseter(authHelper: authHelper)
        let progress: Double = 0.6
        
        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        // then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        // given
        let authHelper = AuthHelper()
        let presenter = WebViewPreseter(authHelper: authHelper)
        let progress: Double = 1.0
        
        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        // then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        // given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        // when
        let url = authHelper.authURL()
        let urlString = url.absoluteString
        
        // then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        // given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")
        urlComponents?.queryItems = []
        urlComponents?.queryItems?.append(URLQueryItem(name: "code", value: "test code"))
        guard let url = urlComponents?.url else { return }
        let authHelper = AuthHelper()

        // when
        let extractedCode = authHelper.code(from: url)

        // then
        XCTAssertEqual(extractedCode, "test code")
    }
}

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
