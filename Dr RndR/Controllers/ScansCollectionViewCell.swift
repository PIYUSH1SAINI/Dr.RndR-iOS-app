import UIKit

// Collection view cell for displaying scanned models
class ScansCollectionViewCell: UICollectionViewCell {
    
    // Delegate to handle cell interaction
    weak var delegate: ScansCollectionViewCellDelegate?
    
    // Properties
    var modelId: String = ""
    var roomId: String = ""
    
    // Outlets for UI elements
    @IBOutlet var scanImageView: UIImageView!
    @IBOutlet var scanLabelView: UILabel!
    @IBOutlet var arButton: UIButton!
    @IBOutlet var threeDButton: UIButton!
    
    // Configure the cell when it's loaded from the storyboard
    override func awakeFromNib() {
        super.awakeFromNib()
        arButton.tintColor = .white
        threeDButton.tintColor = .white
    }
    
    // Action when AR button is tapped
    @IBAction func didTapARButton(_ sender: Any) {
        self.delegate?.didTapAR(for: self)
    }
    
    // Action when 3D button is tapped
    @IBAction func didTapThreeDButton(_ sender: Any) {
        self.delegate?.didTapThreeD(for: self)
    }
}

// Protocol to handle cell interaction
protocol ScansCollectionViewCellDelegate: AnyObject {
    func didTapAR(for cell: ScansCollectionViewCell)
    func didTapThreeD(for cell: ScansCollectionViewCell)
}
