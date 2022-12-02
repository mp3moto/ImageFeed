import UIKit

final class SplashViewController: UIViewController {
    private let showTabBarViewSegueIdentifier = "ShowTabBarView"
    private let storage: OAuth2TokenStorage = OAuth2TokenStorage()
    private let networkClient: NetworkRouting = NetworkClient()

    func loadUserData(token: String, completion: @escaping (Result<UnsplashProfileData, Error>) -> Void) {
        self.networkClient.fetch(url: ProfileDataURL!, method: "GET", userData: nil, headers: ["Authorization": "Bearer \(token)"],queryItemsInURL: true, handler: { result in
            switch result {
            case .success(let rawData):
                do {
                    let JSONtoStruct = try JSONDecoder().decode(UnsplashProfileData.self, from: rawData)
                    completion(.success(JSONtoStruct))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if let token = storage.token {
            loadUserData(token: token, completion: { result in
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let unsplashProfileData):
                    if !unsplashProfileData.id.isEmpty {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: self.showTabBarViewSegueIdentifier, sender: nil)
                        }
                    } else {
                        print("error occured: wrong data")
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
                        }
                    }
                }
            })
        } else {
            performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case showAuthViewSegueIdentifier:
            _ = segue.destination as! AuthViewController
        case showTabBarViewSegueIdentifier:
            _ = segue.destination as! TabBarController
        default:
            super.prepare(for: segue, sender: sender)
        }
    }
}
