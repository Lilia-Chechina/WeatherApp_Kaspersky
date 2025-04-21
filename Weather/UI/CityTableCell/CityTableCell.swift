import UIKit
import SDWebImage

final class CityTableCell: UITableViewCell {

    // MARK: - Internal Types

    typealias ViewModel = CityTableCellViewModel

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var localTimeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!

    static var reuseIdentifier: String {
        return "CityTableCell"
    }

    static var nib: UINib {
        return .init(nibName: reuseIdentifier, bundle: .main)
    }

    func configure(with viewModel: ViewModel) {
        nameLabel.text = viewModel.name
        localTimeLabel.text = viewModel.currentLocalTime
        temperatureLabel.text = viewModel.temperature
        conditionLabel.text = viewModel.conditionText
        if let iconURL = viewModel.conditionIconURL,
           let imageURL = URL(string: iconURL) {
            conditionImageView.sd_setImage(with: imageURL)
        }
    }

}
