import UIKit

class AddViewController: UIViewController {
    
    // Outlets
    @IBOutlet var segmentedView: UISegmentedControl!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var wallsColor: [UIButton]!
    
    // Property to store the selected button title
    var buttonTitle: String = "white"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set initial text label
        textLabel.text = "white"
        
        // Toggle color buttons visibility
        toggleColorButtonsVisibility(isVisible: true)
        
        // Add target for color buttons
        for button in wallsColor {
            button.addTarget(self, action: #selector(wallsColorButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    // Handle tap on color buttons
    @objc func wallsColorButtonTapped(_ sender: UIButton) {
        if let buttonTitle = sender.titleLabel?.text {
            Swift.print("Button tapped with title: \(buttonTitle)")
            ARModelManager().setButtonTitle(buttonTitle)
            textLabel.text = buttonTitle
        }
    }

    // Handle segmented control value change
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        switch segmentedView.selectedSegmentIndex {
        case 0:
            textLabel.text = buttonTitle
            toggleColorButtonsVisibility(isVisible: true)
        case 1:
            textLabel.text = "Second"
            toggleColorButtonsVisibility(isVisible: false)
        case 2:
            textLabel.text = "Third"
            toggleColorButtonsVisibility(isVisible: false)
        default:
            break
        }
    }
    
    // Toggle visibility of color buttons
    private func toggleColorButtonsVisibility(isVisible: Bool) {
        for button in wallsColor {
            button.isHidden = !isVisible
        }
    }
}
