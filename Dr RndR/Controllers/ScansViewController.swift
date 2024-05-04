import UIKit

// View controller for displaying scanned models in a room
class ScansViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ScansCollectionViewCellDelegate {
    
    // Outlets for UI elements
    @IBOutlet var topImageView: UIImageView! // Top image view displaying room image
    @IBOutlet var scansCollectionView: UICollectionView! // Collection view displaying scanned models
    
    // Properties
    var roomId: String = "" // ID of the room
    var roomModels: [ScannedModel] = []  // Models filtered by room
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set corner radius for the top image view
        topImageView.layer.cornerRadius = 10
        
        // Load models specific to the room
        loadModelsForRoom()
        
        // Register collection view cell
        let nibCell = UINib(nibName: "ScansCollectionViewCell", bundle: nil)
        scansCollectionView.register(nibCell, forCellWithReuseIdentifier: "cell")
    }
    
    // Method to load models specific to the room
    func loadModelsForRoom() {
        // Access RoomDataManager to fetch models specific to the room
        if let room = RoomDataManager.shared.rooms.first(where: { $0.id == roomId }) {
            roomModels = room.models
        } else {
            print("No room found with the ID: \(roomId)")
        }

        // Debug to confirm the loaded models
        print("Room ID: \(roomId)")
        print("Number of models in room: \(roomModels.count)")
        
        // Reload collection view to display the models
        scansCollectionView.reloadData()
    }

    // Number of items in the collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return roomModels.count
    }

    // Configure cells in the collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ScansCollectionViewCell else {
            return UICollectionViewCell()
        }

        let model = roomModels[indexPath.row]
        cell.scanImageView.image = UIImage(named: "placeholder")  // Placeholder image, replace as needed
        cell.scanLabelView.text = model.modelName
        cell.delegate = self
        cell.modelId = model.id
        
        return cell
    }

    // Add other UICollectionViewDelegate, UICollectionViewDataSource methods as needed

    // Delegate method for handling AR action in cells
    func didTapAR(for cell: ScansCollectionViewCell) {
        performSegue(withIdentifier: "viewModelARSegue", sender: cell)
    }

    // Delegate method for handling 3D action in cells
    func didTapThreeD(for cell: ScansCollectionViewCell) {
        performSegue(withIdentifier: "viewModelThreeDSegue", sender: cell)
    }
    
    // Prepare for segue to the detail view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Ensure the sender is of type ScansCollectionViewCell
        guard let cell = sender as? ScansCollectionViewCell else {
            print("Sender is not of type ScansCollectionViewCell")
            return
        }

        // Get the model ID from the cell
        let modelId = cell.modelId

        // Determine which segue is being performed and set up the destination view controller
        if segue.identifier == "viewModelARSegue" {
            // Ensure the destination is of type ModelViewController and set the modelId
            if let destinationVC = segue.destination as? ModelViewController {
                destinationVC.modelId = modelId
                destinationVC.roomId = roomId
                /*destinationVC.delegate = self */ // Set delegate if needed and your class conforms to the appropriate protocol
            }
        } else if segue.identifier == "viewModelThreeDSegue" {
            // Ensure the destination is of type SCNViewController and set the modelId
            if let destinationVC = segue.destination as? SCNViewController {
                destinationVC.modelId = modelId
                destinationVC.roomId = roomId
                /*destinationVC.rendererDelegate = self */ // Set the renderer delegate if needed and your class conforms
            }
        }
    }
}
