
import UIKit
import SceneKit

class SCNViewController: UIViewController, SCNSceneRendererDelegate {

    @IBOutlet var sceneViewViewSCN: SCNView!
    @IBOutlet weak var adButton: UIButton!
    var modelURL: URL?
    
    var modelName: String = ""
    var initialModelName: String?

    var modelNode: SCNNode!
    var originalTransform = SCNMatrix4Identity
    
    var modelId: String = ""
    var roomId: String = ""

    override func viewDidLoad() {
            super.viewDidLoad()
            
        if let room = RoomDataManager.shared.rooms.first(where: { $0.id == roomId }),
           let model = room.models.first(where: { $0.id == modelId }) {
                modelName = model.modelName
                self.modelURL = model.filePath
                displayModel(from: model.filePath)
        } else {
            print("No model found for roomId: \(roomId) and modelId: \(modelId)")
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tutorialVC = storyboard.instantiateViewController(withIdentifier: "TutorialARViewController") as? TutorialARViewController {
            present(tutorialVC, animated: true, completion: nil)
        }
        
        let modalVC = TutorialARViewController()
        let navController = UINavigationController(rootViewController: modalVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
            
            addGestures()
        }

    func addGestures() {

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneViewViewSCN.addGestureRecognizer(tapGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        sceneViewViewSCN.addGestureRecognizer(pinchGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        sceneViewViewSCN.addGestureRecognizer(longPressGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        sceneViewViewSCN.addGestureRecognizer(panGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        sceneViewViewSCN.addGestureRecognizer(doubleTapGesture)
        
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        sceneViewViewSCN.addGestureRecognizer(rotateGesture)
    }
    
    func printNodeNames(node: SCNNode, indent: String = "") {
        print("\(indent)\(node.name ?? "Unnamed Node")")
        for child in node.childNodes {
            printNodeNames(node: child, indent: indent + "  ")
        }
    }

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard gesture.state == .changed else { return }
        
        let translation = gesture.translation(in: sceneViewViewSCN)
        
        let modelNode = sceneViewViewSCN.scene!.rootNode.childNode(withName: modelName, recursively: true) ?? sceneViewViewSCN.scene!.rootNode
        
        let currentPosition = modelNode.position
        let newPosition = SCNVector3(x: currentPosition.x + Float(translation.x / 100),
                                     y: currentPosition.y - Float(translation.y / 100),
                                     z: currentPosition.z)
        modelNode.position = newPosition
        gesture.setTranslation(.zero, in: sceneViewViewSCN)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: sceneViewViewSCN)
            let hitResults = sceneViewViewSCN.hitTest(location, options: nil)

            if let modelName = getModelName(fromTap: gesture) {
                print("Model name: \(modelName)")
                self.modelName = initialModelName ?? ""
            }
        }
    
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: sceneViewViewSCN)
        let hitResults = sceneViewViewSCN.hitTest(location, options: nil)
        
        if let result = hitResults.first {
            if let nodeName = result.node.name {
                print("Model name: \(nodeName)")
                modelName = nodeName
            }
        }
    }

    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard gesture.state == .changed else { return }
        
        var modelName = getModelNameFromURL(modelURL!)
        guard let modelNode = sceneViewViewSCN.scene!.rootNode.childNode(withName: modelName!, recursively: true) else { return }
        let currentScale = modelNode.scale
        let newScale = SCNVector3(x: currentScale.x * Float(gesture.scale),
                                  y: currentScale.y * Float(gesture.scale),
                                  z: currentScale.z * Float(gesture.scale))
        modelNode.scale = newScale
        gesture.scale = 1.0
    }
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        var ARModelManager: ARModelManager = ARModelManager()
        if gesture.state == .began {
            let location = gesture.location(in: sceneViewViewSCN)
            let hitResults = sceneViewViewSCN.hitTest(location, options: nil)
            
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
    @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        if gesture.state == .changed || gesture.state == .began {
            guard let modelNode = sceneViewViewSCN.scene!.rootNode.childNode(withName: modelName, recursively: true) else { return }
            let rotation = Float(gesture.rotation)
            print("Gesture rotation: \(rotation)")
   
            let rotationMatrix = SCNMatrix4MakeRotation(rotation, 0, 1, 0)
            modelNode.transform = SCNMatrix4Mult(modelNode.transform, rotationMatrix)

            gesture.rotation = 0
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
        let location = gesture.location(in: sceneViewViewSCN)
        let hitResults = sceneViewViewSCN.hitTest(location, options: nil)
        
        if let result = hitResults.first {
            if let nodeName = result.node.name {
                return nodeName
            }
        }
        return nil
    }
    
    func displayModel(from url: URL) {
        do {
            let scene = try SCNScene(url: url)
            
            var modelName = getModelNameFromURL(modelURL!)
            if let modelNode = scene.rootNode.childNode(withName: modelName!, recursively: true) {
                self.modelNode = modelNode
                
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
                
                sceneViewViewSCN.scene = scene
                sceneViewViewSCN.backgroundColor = UIColor.darkGray
                printNodeNames(node: scene.rootNode)
            }
            else
            {
                print("Model node not found in the scene.")
            }
        }
        catch
            {
                print("Error loading scene: \(error.localizedDescription)")
            }
    }

}
