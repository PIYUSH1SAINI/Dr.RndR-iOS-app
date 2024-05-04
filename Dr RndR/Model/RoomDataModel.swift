import Foundation

struct Room {
    let id: String
    var name: String
    var models: [ScannedModel]
}

class RoomDataManager {
    var roomsSaved: [Room] = []

    // Function to add a room to the array
    func addRoom(_ room: Room) {
        roomsSaved.append(room)
    }

    // Function to get a room from the array based on its ID
    func getRoom(withID id: String) -> Room? {
        return roomsSaved.first { $0.id == id }
    }
}

let roomdata = RoomDataManager().addRoom(Room(id: UUID().uuidString, name: "Bedroom", models: []))
