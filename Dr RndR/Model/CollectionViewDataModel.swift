import Foundation

struct ScannedModel: Codable {
    let id: String
    let modelName: String
    let filePath: URL
    var roomName: String
}
class CollectionViewModelManager {
    
    func addScannedModel(modelName: String, filePath: URL, roomName: String) {
        let id = UUID()
        let newModel = ScannedModel(id: id.uuidString, modelName: modelName, filePath: filePath, roomName: roomName)
        RoomDataManager.shared.addModelToRoom(model: newModel, roomName: roomName)
    }
    
    func saveScannedModels() {
        RoomDataManager.shared.saveRooms()
    }
    
    func loadScannedModels() {
        RoomDataManager.shared.loadRooms()
    }
    
    func addDemoData() {
        let demoModels = [
            ScannedModel(id: UUID().uuidString, modelName: "Chair Model", filePath: URL(fileURLWithPath: "/path/to/demo/chair.usdz"), roomName: "LivingRoom"),
            ScannedModel(id: UUID().uuidString, modelName: "Table Model", filePath: URL(fileURLWithPath: "/path/to/demo/table.usdz"), roomName: "DiningRoom"),
            ScannedModel(id: UUID().uuidString, modelName: "Bed Model", filePath: URL(fileURLWithPath: "/path/to/demo/bed.usdz"), roomName: "BedRoom")
        ]

        for model in demoModels {
            RoomDataManager.shared.addModelToRoom(model: model, roomName: model.roomName)
        }

        RoomDataManager.shared.saveRooms()
    }
}
