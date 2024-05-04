import UIKit



struct Room {
    var id: String
    var name: String
    var image: UIImage
    var models: [ScannedModel] = []
    mutating func addModel(_ model: ScannedModel) {
        models.append(model)
    }
}
class RoomDataManager {
    
    func addRoom(_ room: Room) {
            if !rooms.contains(where: { $0.name == room.name }) {
                rooms.append(room)
                saveRooms()
            } else {
                print("A room with the name \(room.name) already exists.")
            }
        }
    
    func getAllRooms() -> [Room] {
            return rooms
        }
    
    static let shared = RoomDataManager()
    var rooms: [Room] = []

    init() {
        loadDefaultRooms()
    }
    
    func loadDefaultRooms() {
            if let bedImage = UIImage(named: "Bed") {
                rooms.append(Room(id: UUID().uuidString, name: "BedRoom", image: bedImage))
            } else {
                print("Warning: Bed image not found!")
            }

            if let livingRoomImage = UIImage(named: "livingRoom") {
                rooms.append(Room(id: UUID().uuidString,name: "LivingRoom", image: livingRoomImage))
            } else {
                print("Warning: Living room image not found!")
            }

            if let diningRoomImage = UIImage(named: "dinningroom1") {
                rooms.append(Room(id: UUID().uuidString,name: "DiningRoom", image: diningRoomImage))
            } else {
                print("Warning: Dining room image not found!")
            }
        }

    func addModelToRoom(model: ScannedModel, roomName: String) {
        if let index = rooms.firstIndex(where: { $0.name == roomName }) {
            rooms[index].models.append(model)
        } else {
            let newRoom = Room(id: UUID().uuidString,name: roomName, image: UIImage(named: "defaultImage") ?? UIImage(), models: [model])
            rooms.append(newRoom)
        }
        saveRooms()
    }

    func saveRooms() {
    }

    func loadRooms() {
    }
}
