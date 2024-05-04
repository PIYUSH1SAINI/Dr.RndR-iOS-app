import UIKit
import SceneKit
import ARKit

class ModelViewController: UIViewController, ARSCNViewDelegate {

    var roomId: String = ""
    var selectedModel: ScannedModel?
    
    @IBOutlet var arView: UIView!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var addButton: UIButton!
    
    var scaleFactor: Float = 1.0
    var rotationX: Float = 0.0
    var rotationY: Float = 0.0
    var translationX: Float = 0.0
    var translationY: Float = 0.0
    
    var modelURL: URL?
    var chairNode: SCNNode?
    var roomAnchor: ARAnchor?
    var modelName: String = ""
    var modelId: String = ""

    
    override func viewDidLoad() {
            super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tutorialVC = storyboard.instantiateViewController(withIdentifier: "TutorialARViewController") as? TutorialARViewController {
                present(tutorialVC, animated: true, completion: nil)
            }
        
        let modalVC = TutorialARViewController()
        let navController = UINavigationController(rootViewController: modalVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)

            sceneView.delegate = self
            sceneView.isUserInteractionEnabled = true
            
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            sceneView.session.run(configuration)

            if let room = RoomDataManager.shared.rooms.first(where: { $0.id == roomId }),
               let firstModel = room.models.first(where: { $0.id == modelId }) {
                displayModel(from: firstModel.filePath)
                initialModelName = firstModel.modelName
            } else {
                print("No model or room found for room ID: \(roomId)")
            }
        
            setupGestures()
        }

        private func setupGestures() {
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            sceneView.addGestureRecognizer(tapGesture)
            
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            sceneView.addGestureRecognizer(pinchGesture)

            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            sceneView.addGestureRecognizer(longPressGesture)
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            sceneView.addGestureRecognizer(panGesture)
            
            let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
            sceneView.addGestureRecognizer(rotateGesture)
            
            let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
            doubleTapGesture.numberOfTapsRequired = 2
            sceneView.addGestureRecognizer(doubleTapGesture)
            
            sceneView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:))))
        }
    var initialModelName: String?
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard gesture.state == .changed else { return }
        guard let modelNode = sceneView.scene.rootNode.childNode(withName: modelName, recursively: true) else { return }
        let currentScale = modelNode.scale
        let newScale = SCNVector3(x: currentScale.x * Float(gesture.scale),
                                  y: currentScale.y * Float(gesture.scale),
                                  z: currentScale.z * Float(gesture.scale))
        modelNode.scale = newScale
        gesture.scale = 1.0
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        
        if let hit = hitResults.first {
            // Get the node that was tapped
            let tappedNode = hit.node
            
            // Find the parent node that represents the entire model
            var parentNode = tappedNode
            while parentNode.parent != nil {
                if parentNode.name == modelName {
                    // Found the parent node representing the entire model
                    break
                }
                parentNode = parentNode.parent!
            }
            
            // Set the model name to the name of the parent node
            modelName = parentNode.name ?? ""
            
            // Debug print to confirm the model name
            print("Model name: \(modelName)")
        }
    }



    func getModelNameFromURL(_ url: URL) -> String? {
        let lastPathComponent = url.lastPathComponent
        let components = lastPathComponent.components(separatedBy: ".")
        if let modelName = components.first {
            return modelName
        }
        return nil
    }

    func getModelName(fromTap gesture: UITapGestureRecognizer) -> String? {
        let location = gesture.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        
        if let result = hitResults.first {
            if let nodeName = result.node.name {
                return nodeName
            }
        }
        return nil
    }

    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        
        if let result = hitResults.first {
            if let nodeName = result.node.name {
                print("Model name: \(nodeName)")
                modelName = nodeName
            }
        }
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        var ARModelManager: ARModelManager = ARModelManager()
        if gesture.state == .began {
            let location = gesture.location(in: sceneView)
            let hitResults = sceneView.hitTest(location, options: nil)
            
            if let result = hitResults.first {
                let tappedNode = result.node
                print("Node tapped:- \(tappedNode)")
                
                if let geometry = tappedNode.geometry {
                    if let buttonTitle = ARModelManager.getButtonTitle() {
                        var color: UIColor?
                        switch buttonTitle {
                        case "green":
                            color = .green
                        case "purple":
                            color = .purple
                        case "blue":
                            color = .blue
                        case "black":
                            color = .black
                        case "white":
                            color = .white
                        case "lightgrey":
                            color = .lightGray
                        case "lightbrown":
                            color = .systemBrown
                        case "darkbrown":
                            color = .brown
                        case "darkgrey":
                            color = .darkGray
                        default:
                            print("Color not found: \(buttonTitle)")
                            return
                        }
                        geometry.firstMaterial?.diffuse.contents = color
                    }
                }
                print("Button title inside model-view-controller: \(buttonTitle)")
            }
        }
    }

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard gesture.state == .changed else { return }
        let translation = gesture.translation(in: sceneView)
        guard let modelNode = sceneView.scene.rootNode.childNode(withName: modelName, recursively: true) else { return }
        let currentPosition = modelNode.position
        let newPosition = SCNVector3(x: currentPosition.x + Float(translation.x / 100),
                                     y: currentPosition.y - Float(translation.y / 100),
                                     z: currentPosition.z)
        modelNode.position = newPosition
        gesture.setTranslation(.zero, in: sceneView)
    }

    @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard gesture.state == .changed else { return }
        guard let modelNode = sceneView.scene.rootNode.childNode(withName: modelName, recursively: true) else { return }
        modelNode.eulerAngles.y -= Float(gesture.rotation)
        gesture.rotation = 0
    }

    func displayModel(from url: URL) {
        do {
            let scene = try SCNScene(url: url)
            let modelName = getModelNameFromURL(url)
            
            if let modelNode = scene.rootNode.childNode(withName: modelName!, recursively: true) {
                // Assign modelName based on the loaded model node's name
                self.modelName = modelName ?? ""
                
                let lightNode = SCNNode()
                lightNode.light = SCNLight()
                lightNode.light?.type = .omni
                lightNode.position = SCNVector3(x: 0, y: 10, z: 20)
                scene.rootNode.addChildNode(lightNode)
                
                let ambientLightNode = SCNNode()
                ambientLightNode.light = SCNLight()
                ambientLightNode.light?.type = .ambient
                ambientLightNode.light?.color = UIColor.darkGray
                scene.rootNode.addChildNode(ambientLightNode)
                
                sceneView.scene = scene
                sceneView.backgroundColor = UIColor.black
            } else {
                print("Model node not found in the scene.")
            }
        } catch {
            print("Error loading scene: \(error.localizedDescription)")
        }
    }

    
//    @IBAction func threeDButtonPressed(_ sender: UIButton) {
//            threeDButton.tintColor = UIColor.link
//            arButton.tintColor = UIColor.gray
//            arView.isHidden = true
//            threeDView.isHidden = false
//        }
//
//        @IBAction func arButtonPressed(_ sender: UIButton) {
//            arButton.tintColor = UIColor.link
//            threeDButton.tintColor = UIColor.gray
//            arView.isHidden = false
//            threeDView.isHidden = true
//            addButton.tintColor = UIColor.white
//        }
 
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if anchor == roomAnchor, let chairNode = chairNode {
            let transform = SCNMatrix4(anchor.transform)
            let position = SCNVector3(transform.m41, transform.m42, transform.m43)
            let rotation = SCNVector4(transform.m11, transform.m12, transform.m13, transform.m14)
            chairNode.position = position
            chairNode.rotation = rotation
        }
    }
}








//import UIKit
//import SceneKit
//import ARKit
//
//class ModelViewController: UIViewController, ARSCNViewDelegate {
//
////    @IBOutlet var threeDButton: UIButton!
////    @IBOutlet var arButton: UIButton!
////    @IBOutlet var threeDView: UIView!
//    @IBOutlet var arView: UIView!
//    @IBOutlet var sceneView: ARSCNView!
//    @IBOutlet var addButton: UIButton!
//    
//    var scaleFactor: Float = 1.0
//    var rotationX: Float = 0.0
//    var rotationY: Float = 0.0
//    var translationX: Float = 0.0
//    var translationY: Float = 0.0
//    
//    var modelURL: URL?
//    var chairNode: SCNNode?
//    var roomAnchor: ARAnchor?
//    var modelName: String = ""
//    var modelId: String = ""
//    var roomId: String = ""
//    
//    override func viewDidLoad() {
//            super.viewDidLoad()
//        
//        if let room = RoomDataManager.shared.rooms.first(where: { $0.id == roomId }),
//                          let model = room.models.first(where: { $0.id == modelId }) {
//                           displayModel(from: model.filePath)
//                           modelName = model.modelName
//                   self.modelURL = model.filePath
//                print(modelURL)
//                       } else {
//                           print("No model found for roomId: \(roomId) and modelId: \(modelId)")
//                       }
//
//            // Configure SceneView
//            sceneView.delegate = self
//            sceneView.isUserInteractionEnabled = true
//            
//            // Start AR session
//            let configuration = ARWorldTrackingConfiguration()
//            configuration.planeDetection = .horizontal
//            sceneView.session.run(configuration)
//
//            
//            
//            // Setup gestures
//            setupGestures()
//        }
//
//        private func setupGestures() {
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//            sceneView.addGestureRecognizer(tapGesture)
//            
//            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
//            sceneView.addGestureRecognizer(pinchGesture)
//
//            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
//            sceneView.addGestureRecognizer(longPressGesture)
//            
//            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
//            sceneView.addGestureRecognizer(panGesture)
//            
//            let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
//            sceneView.addGestureRecognizer(rotateGesture)
//            
//            let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
//            doubleTapGesture.numberOfTapsRequired = 2
//            sceneView.addGestureRecognizer(doubleTapGesture)
//            
//            sceneView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:))))
//        }
//    var initialModelName: String?
//    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
//        guard gesture.state == .changed else { return }
//        guard let modelNode = sceneView.scene.rootNode.childNode(withName: modelName, recursively: true) else { return }
//        let currentScale = modelNode.scale
//        let newScale = SCNVector3(x: currentScale.x * Float(gesture.scale),
//                                  y: currentScale.y * Float(gesture.scale),
//                                  z: currentScale.z * Float(gesture.scale))
//        modelNode.scale = newScale
//        gesture.scale = 1.0
//    }
//
//    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
//            let location = gesture.location(in: sceneView)
//            let hitResults = sceneView.hitTest(location, options: nil)
//
//            if let modelName = getModelName(fromTap: gesture) {
//                print("Model name: \(modelName)")
//                self.modelName = initialModelName ?? ""
//            }
//        }
//
//    func getModelNameFromURL(_ url: URL) -> String? {
//        let lastPathComponent = url.lastPathComponent
//        let components = lastPathComponent.components(separatedBy: ".")
//        if let modelName = components.first {
//            return modelName
//        }
//        return nil
//    }
//
//    func getModelName(fromTap gesture: UITapGestureRecognizer) -> String? {
//        let location = gesture.location(in: sceneView)
//        let hitResults = sceneView.hitTest(location, options: nil)
//        
//        if let result = hitResults.first {
//            if let nodeName = result.node.name {
//                return nodeName
//            }
//        }
//        return nil
//    }
//
//    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
//        let location = gesture.location(in: sceneView)
//        let hitResults = sceneView.hitTest(location, options: nil)
//        
//        if let result = hitResults.first {
//            if let nodeName = result.node.name {
//                print("Model name: \(nodeName)")
//                modelName = nodeName
//            }
//        }
//    }
//    
//    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
//        var ARModelManager: ARModelManager = ARModelManager()
//        if gesture.state == .began {
//            let location = gesture.location(in: sceneView)
//            let hitResults = sceneView.hitTest(location, options: nil)
//            
//            if let result = hitResults.first {
//                let tappedNode = result.node
//                print("Node tapped:- \(tappedNode)")
//                
//                if let geometry = tappedNode.geometry {
//                    if let buttonTitle = ARModelManager.getButtonTitle() {
//                        var color: UIColor?
//                        switch buttonTitle {
//                        case "green":
//                            color = .green
//                        case "purple":
//                            color = .purple
//                        case "blue":
//                            color = .blue
//                        case "black":
//                            color = .black
//                        case "white":
//                            color = .white
//                        case "lightgrey":
//                            color = .lightGray
//                        case "lightbrown":
//                            color = .systemBrown
//                        case "darkbrown":
//                            color = .brown
//                        case "darkgrey":
//                            color = .darkGray
//                        default:
//                            print("Color not found: \(buttonTitle)")
//                            return
//                        }
//                        geometry.firstMaterial?.diffuse.contents = color
//                    }
//                }
//                print("Button title inside model-view-controller: \(buttonTitle)")
//            }
//        }
//    }
//
//    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
//        guard gesture.state == .changed else { return }
//        let translation = gesture.translation(in: sceneView)
//        guard let modelNode = sceneView.scene.rootNode.childNode(withName: modelName, recursively: true) else { return }
//        let currentPosition = modelNode.position
//        let newPosition = SCNVector3(x: currentPosition.x + Float(translation.x / 100),
//                                     y: currentPosition.y - Float(translation.y / 100),
//                                     z: currentPosition.z)
//        modelNode.position = newPosition
//        gesture.setTranslation(.zero, in: sceneView)
//    }
//
//    @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
//        guard gesture.state == .changed else { return }
//        guard let modelNode = sceneView.scene.rootNode.childNode(withName: modelName, recursively: true) else { return }
//        modelNode.eulerAngles.y -= Float(gesture.rotation)
//        gesture.rotation = 0
//    }
//
//    func displayModel(from url: URL) {
//        do {
//            let scene = try SCNScene(url: url)
//            let lightNode = SCNNode()
//            lightNode.light = SCNLight()
//            lightNode.light?.type = .omni
//            lightNode.position = SCNVector3(x: 0, y: 10, z: 20)
//            scene.rootNode.addChildNode(lightNode)
//            
//            let ambientLightNode = SCNNode()
//            ambientLightNode.light = SCNLight()
//            ambientLightNode.light?.type = .ambient
//            ambientLightNode.light?.color = UIColor.darkGray
//            scene.rootNode.addChildNode(ambientLightNode)
//            sceneView.scene = scene
//            sceneView.backgroundColor = UIColor.black
//        } catch {
//            print("Error loading scene: \(error.localizedDescription)")
//        }
//    }
// 
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        if anchor == roomAnchor, let chairNode = chairNode {
//            let transform = SCNMatrix4(anchor.transform)
//            let position = SCNVector3(transform.m41, transform.m42, transform.m43)
//            let rotation = SCNVector4(transform.m11, transform.m12, transform.m13, transform.m14)
//            chairNode.position = position
//            chairNode.rotation = rotation
//        }
//    }
//}
