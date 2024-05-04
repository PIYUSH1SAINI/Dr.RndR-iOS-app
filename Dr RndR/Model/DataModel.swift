//import Foundation
//
//struct Model{
//    let id: String
//    let modelName: String
//    let filePath: URL
//    var images: String
//    
//}
//
//struct Room {
//    let id: String
//    var name: String
//    var models: [Model]
//}
//
//struct ScannedModel: Codable {
//    let id: UUID
//    let modelName: String
//    let filePath: URL
//}
//
//var buttonTitle: String = "white"
//
//class ScannedModelManager {
//    var scannedModels: [ScannedModel] = []
//    
//    
//    func setButtonTitle(_ title: String) {
//        buttonTitle = title
//    }
//    func getButtonTitle() -> String? {
//        return buttonTitle
//    }
//    
//    
//    func addScannedModel(modelName: String, filePath: URL) {
//        let id = UUID()
//        let scannedModel = ScannedModel(id: id, modelName: modelName, filePath: filePath)
//        scannedModels.append(scannedModel)
//        saveScannedModels()
//    }
//    
//    func getAllScannedModels() -> [ScannedModel] {
//        loadScannedModels()
//        return scannedModels
//    }
//    
//    func getModelName(from filePath: URL) -> String? {
//        let fileName = filePath.lastPathComponent
//        let modelName = (fileName as NSString).deletingPathExtension
//        return modelName.isEmpty ? nil : modelName
//    }
//    
//    private func saveScannedModels() {
//        let encoder = JSONEncoder()
//        if let encodedData = try? encoder.encode(scannedModels) {
//            UserDefaults.standard.set(encodedData, forKey: "ScannedModels")
//        }
//    }
//    
//    private func loadScannedModels() {
//        if let savedData = UserDefaults.standard.data(forKey: "ScannedModels") {
//            let decoder = JSONDecoder()
//            if let loadedModels = try? decoder.decode([ScannedModel].self, from: savedData) {
//                scannedModels = loadedModels
//            }
//        }
//    }
//}
//
//var roomsSaved: [Room] = []
