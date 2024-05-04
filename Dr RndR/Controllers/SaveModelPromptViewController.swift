import UIKit

class SaveModelPromptViewController: UIViewController {

    // Outlets
    @IBOutlet weak var thumbnailImageView: UIImageView! // Image view for displaying a thumbnail of the model
    @IBOutlet weak var editPhotoButton: UIButton! // Button for editing the model's photo
    @IBOutlet weak var roomNameTextField: UITextField! // Text field for entering the room name
    @IBOutlet weak var modelNameTextField: UITextField! // Text field for entering the model name
    
    // Properties
    var modelPath: URL? // File path of the model
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply corner radius to UI elements
        thumbnailImageView.layer.cornerRadius = 10
        editPhotoButton.layer.cornerRadius = 10
        roomNameTextField.layer.cornerRadius = 10
        modelNameTextField.layer.cornerRadius = 10
        
        // Setup additional views
        setupViews()
    }

    // Setup additional views
    private func setupViews() {
        thumbnailImageView.layer.cornerRadius = 10
        thumbnailImageView.clipsToBounds = true
    }
    
    // Cancel button action
    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Save button action
    @IBAction func didTapSave(_ sender: Any) {
        saveModel()
    }
    
    // Save the model
    private func saveModel() {
        // Check if room name and model name are provided
        guard let roomName = roomNameTextField.text, !roomName.isEmpty,
              let modelName = modelNameTextField.text, !modelName.isEmpty else {
            presentAlert(title: "Error", message: "Please fill all fields.")
            return
        }

        // Create a new ScannedModel object with provided details
        let newModel = ScannedModel(id: UUID().uuidString, modelName: modelName, filePath: modelPath!, roomName: roomName)
        
        // Add the model to the room data manager
        RoomDataManager.shared.addModelToRoom(model: newModel, roomName: roomName)
        
        // Print confirmation message
        print("Model saved: \(modelName) in \(roomName)")
        
        // Dismiss the view controller
        dismiss(animated: true, completion: nil)
    }

    // Present an alert
    func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
