import UIKit
import RoomPlan

// View controller for capturing a room using AR
class RoomCaptureViewController: UIViewController, RoomCaptureViewDelegate, RoomCaptureSessionDelegate {
    
    // Outlets
    @IBOutlet var exportButton: UIButton? // Button to export captured room
    @IBOutlet var doneButton: UIBarButtonItem? // Button to finish scanning
    @IBOutlet var cancelButton: UIBarButtonItem? // Button to cancel scanning
    @IBOutlet var activityIndicator: UIActivityIndicatorView? // Activity indicator
    
    // Properties
    var capturedRoomURL: URL! // URL for the captured room
    private var modelID: String? // ID of the captured model
    private var modelName: String? // Name of the captured model
    private var isScanning: Bool = false // Flag indicating if scanning is in progress
    private var roomCaptureView: RoomCaptureView! // AR view for room capture
    private var roomCaptureSessionConfig: RoomCaptureSession.Configuration = RoomCaptureSession.Configuration() // Configuration for room capture session
    private var finalResults: CapturedRoom? // Final results of room capture
    
    // View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRoomCaptureView()
        activityIndicator?.stopAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSession()
    }
    
    override func viewWillDisappear(_ flag: Bool) {
        super.viewWillDisappear(flag)
        stopSession()
    }
    
    //Setup
    
    private func setupRoomCaptureView() {
        roomCaptureView = RoomCaptureView(frame: view.bounds)
        roomCaptureView.captureSession.delegate = self
        roomCaptureView.delegate = self
        view.insertSubview(roomCaptureView, at: 0)
    }
    
    //Session Control
    
    private func startSession() {
        isScanning = true
        roomCaptureView?.captureSession.run(configuration: roomCaptureSessionConfig)
        setActiveNavBar()
    }
    
    private func stopSession() {
        isScanning = false
        roomCaptureView?.captureSession.stop()
        setCompleteNavBar()
    }
    
    //RoomCaptureViewDelegate
    
    func setActiveNavBar() {
        // Adjust navigation bar for active scanning
        UIView.animate(withDuration: 1.0, animations: {
            self.cancelButton?.tintColor = .white
            self.doneButton?.tintColor = .white
            self.exportButton?.alpha = 0.0
        }) { _ in
            self.exportButton?.isHidden = true
        }
    }
    
    func setCompleteNavBar() {
        // Adjust navigation bar for completed scanning
        exportButton?.isHidden = false
        UIView.animate(withDuration: 1.0) {
            
            
            
            
            self.cancelButton?.tintColor = .systemBlue
            self.doneButton?.tintColor = .systemBlue
            
            self.exportButton?.alpha = 1.0
        }
    }
    
    
    
    func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
        // Handle captured room data
        finalResults = processedResult
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        
        modelID = UUID().uuidString
        modelName = "Room_\(timestamp)"
        
        let fileName = "\(modelName!).usdz"
        let destinationFolderURL = FileManager.default.temporaryDirectory
        capturedRoomURL = destinationFolderURL.appendingPathComponent(fileName)
        do {
            try processedResult.export(to: capturedRoomURL)
        } catch {
            print(error)
        }
        
        exportButton?.isEnabled = true
        activityIndicator?.stopAnimating()
    }
    
    func saveRoomScan(roomName: String, roomCardSelection: String) {
        CollectionViewModelManager().addScannedModel(modelName: roomName, filePath: capturedRoomURL, roomName: roomCardSelection)
    }
    
    func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //Actions
    
    @IBAction func exportResults(_ sender: UIButton) {
        // Action when export button is tapped
        print("Save button clicked")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let navController = storyboard.instantiateViewController(withIdentifier: "SaveModelNavController") as? UINavigationController,
           let saveModelVC = navController.viewControllers.first as? SaveModelPromptViewController {
            // Setting properties before presentation
            saveModelVC.modelPath = capturedRoomURL // Set the modelPath with your specific URL

            // Set the modal presentation style to form sheet which also shows the navigation bar
            navController.modalPresentationStyle = .formSheet
            navController.preferredContentSize = CGSize(width: 600, height: 400) // Adjust size as needed

            // Present the navigation controller modally
            present(navController, animated: true, completion: nil)
        }
    }
    
    @IBAction func doneScanning(_ sender: UIBarButtonItem) {
        // Action when done button is tapped
        if isScanning { stopSession() } else { cancelScanning(sender) }
        self.exportButton?.isEnabled = false
        self.activityIndicator?.startAnimating()
    }

    @IBAction func cancelScanning(_ sender: UIBarButtonItem) {
        // Action when cancel button is tapped
        navigationController?.dismiss(animated: true)
    }
}
