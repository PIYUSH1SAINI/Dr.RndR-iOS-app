import UIKit

// View controller responsible for managing the home screen
class ViewController: UIViewController, UITableViewDataSource, homeTableViewCellDelegate {
    
    // Data manager responsible for managing rooms
    let roomDataManager = RoomDataManager.shared
    
    // Table view displaying rooms
    @IBOutlet var homeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load default rooms
        roomDataManager.loadDefaultRooms()
        
        // Set data source for the table view
        homeTableView.dataSource = self
        
        // Reload the table view to reflect any loaded data
        homeTableView.reloadData()
        
        // Debug print to see the loaded rooms and their details
        let allRoomCards = roomDataManager.getAllRooms()
        for card in allRoomCards {
            print("Room Name: \(card.name), Model Count: \(card.models.count)")
            for model in card.models {
                print("Model Name: \(model.modelName)")
            }
            print("------------")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        homeTableView.reloadData()
    }

    // Number of sections in the table view (one section per room)
    func numberOfSections(in tableView: UITableView) -> Int {
        return roomDataManager.rooms.count
    }
    
    // Number of rows in each section (one row per room)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Keeps one cell per section for simplicity; modify if listing models per room
    }

    // Configure cells in the table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as! HomeTableCellTableViewCell
        let room = roomDataManager.rooms[indexPath.section]
        cell.cellLabel.text = room.name
        cell.homeImageView.image = room.image
        cell.delegate = self
        return cell
    }

    // Action when the add button is tapped
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Enter room name", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Type something here..."
        }
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self] action in
            if let textField = alertController.textFields?.first, let inputText = textField.text, !inputText.isEmpty {
                roomDataManager.addRoom(Room(id: UUID().uuidString,name: inputText, image: UIImage(named: "defaultImage") ?? UIImage()))
                homeTableView.reloadData() // Reload the table view to display the new room
            }
        }
        alertController.addAction(submitAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    // Prepare for segue to the detail view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openedRoom",
           let destinationVC = segue.destination as? ScansViewController,
           let cell = sender as? HomeTableCellTableViewCell,
           let indexPath = homeTableView.indexPath(for: cell) {
            let room = roomDataManager.rooms[indexPath.section]
            destinationVC.roomId = room.id // Assuming room name uniquely identifies a room
        }
    }

    // Delegate method triggered when a cell is tapped
    func didtapCard(for cell: HomeTableCellTableViewCell) {
        performSegue(withIdentifier: "openedRoom", sender: cell)
    }
}
