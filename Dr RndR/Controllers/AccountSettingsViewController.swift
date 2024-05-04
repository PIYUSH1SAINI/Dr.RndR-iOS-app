import UIKit

class AccountSettingsViewController: UIViewController {
    @IBOutlet var accountPhotoView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountPhotoView.layer.cornerRadius = 60
    }
}
