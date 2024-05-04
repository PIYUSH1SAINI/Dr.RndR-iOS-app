import UIKit

// Custom table view cell for displaying room information
class HomeTableCellTableViewCell: UITableViewCell {

    // Outlets for UI elements
    @IBOutlet weak var cellLabel: UILabel! // Label displaying room name
    @IBOutlet weak var homeImageView: UIImageView! // Image view displaying room image
    
    // Identifier for the cell
    var id: String = ""
    
    // Delegate to handle cell interaction
    weak var delegate: homeTableViewCellDelegate?
    
    // Configure the cell when it's loaded from the storyboard
    override func awakeFromNib() {
        super.awakeFromNib()
        cellLabel.text = "Bedroom" // Default label text
    }

    // Override setSelected method
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// Protocol to handle cell interaction
protocol homeTableViewCellDelegate: AnyObject {
    func didtapCard(for cell: HomeTableCellTableViewCell) // Delegate method triggered when a cell is tapped
}
