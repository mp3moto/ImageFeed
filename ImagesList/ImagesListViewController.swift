import UIKit

class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    private var photos: [String] = []

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photos = Array(0..<20).map{ "\($0)" }
    }

    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        print(indexPath.row)
        guard let image = UIImage(named: photos[indexPath.row]) else {
            return
        }
        cell.cellImage.image = image
        let liked: String = indexPath.row % 2 == 0 ? "NoLike" : "Like"
        cell.cellLike.setImage(UIImage(named: liked), for: .normal)
        cell.cellDate.text = dateFormatter.string(from: Date())
    }

}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
