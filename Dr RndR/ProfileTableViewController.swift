import Foundation
import UIKit

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.layer.cornerRadius = 40
    }
}
