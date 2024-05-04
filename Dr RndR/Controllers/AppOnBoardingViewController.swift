import UIKit

// View controller for app onboarding screen
class AppOnBoardingViewController: UIViewController {
    
    // Action triggered when the continue button is tapped
    @IBAction func continueBtn(_ sender: UIButton) {
        // Present the TabBarViewController when the continue button is tapped
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") {
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true)
        }
    }
}
