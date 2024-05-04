//import UIKit
//import SceneKit
//
//class ScanSCNViewController: UIViewController, SCNSceneRendererDelegate {
//    @IBOutlet var sceneViewSCN: SCNView!
//    var modelURL: URL?
//    
//    var modelName: String = ""
//    var initialModelName: String?
//
//    var modelNode: SCNNode!
//    var originalTransform = SCNMatrix4Identity
//    
//    var modelId: String = ""
//    var roomId: String = ""
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let room = roomsSaved.first(where: {$0.id == roomId})
//        let model = room?.models.first(where: {$0.id == modelId})
//        
//        modelURL = model?.filePath
//
//        if let modelURL = modelURL {
//            displayModel(from: modelURL)
//        } else {
//            print("No model URL provided.")
//        }
//        addGestures()
//    }
//
//    func addGestures() {
//
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        sceneViewSCN.addGestureRecognizer(tapGesture)
//        
//        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
//        sceneViewSCN.addGestureRecognizer(pinchGesture)
//        
//        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
//        sceneViewSCN.addGestureRecognizer(longPressGesture)
//        
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
//        sceneViewSCN.addGestureRecognizer(panGesture)
//        
//        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
//        doubleTapGesture.numberOfTapsRequired = 2
//        sceneViewSCN.addGestureRecognizer(doubleTapGesture)
//        
//        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
//        sceneViewSCN.addGestureRecognizer(rotateGesture)
//    }
//
//    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
//        guard gesture.state == .changed else { return }
//        let translation = gesture.translation(in: sceneViewSCN)
//        guard let modelNode = sceneViewSCN.scene!.rootNode.childNode(withName: modelName, recursively: true) else { return }
//        let currentPosition = modelNode.position
//        let newPosition = SCNVector3(x: currentPosition.x + Float(translation.x / 100),
//                                     y: currentPosition.y - Float(translation.y / 100),
//                                     z: currentPosition.z)
//        modelNode.position = newPosition
//        gesture.setTranslation(.zero, in: sceneViewSCN)
//    }
//    
//    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
//            let location = gesture.location(in: sceneViewSCN)
//            let hitResults = sceneViewSCN.hitTest(location, options: nil)
//
//            if let modelName = getModelName(fromTap: gesture) {
//                print("Model name: \(modelName)")
//                self.modelName = initialModelName ?? ""
//            }
//        }
//    
//    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
//        let location = gesture.location(in: sceneViewSCN)
//        let hitResults = sceneViewSCN.hitTest(location, options: nil)
//        
//        if let result = hitResults.first {
//            if let nodeName = result.node.name {
//                print("Model name: \(nodeName)")
//                modelName = nodeName
//            }
//        }
//    }
//
//    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
//        guard gesture.state == .changed else { return }
//        
//        var modelName = getModelNameFromURL(modelURL!)
//        guard let modelNode = sceneViewSCN.scene!.rootNode.childNode(withName: modelName!, recursively: true) else { return }
//        let currentScale = modelNode.scale
//        let newScale = SCNVector3(x: currentScale.x * Float(gesture.scale),
//                                  y: currentScale.y * Float(gesture.scale),
//                                  z: currentScale.z * Float(gesture.scale))
//        modelNode.scale = newScale
//        gesture.scale = 1.0
//    }
//    
//    
//
//    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
//        if gesture.state == .began {
//            let location = gesture.location(in: sceneViewSCN)
//            let hitResults = sceneViewSCN.hitTest(location, options: nil)
//            if let hit = hitResults.first {
//                let node = hit.node
//                node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
//            }
//        }
//    }
//    
//    @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
//        guard gesture.state == .changed else { return }
//        guard let modelNode = sceneViewSCN.scene!.rootNode.childNode(withName: modelName, recursively: true) else { return }
//        modelNode.eulerAngles.y -= Float(gesture.rotation)
//        gesture.rotation = 0
//    }
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
//        let location = gesture.location(in: sceneViewSCN)
//        let hitResults = sceneViewSCN.hitTest(location, options: nil)
//        
//        if let result = hitResults.first {
//            if let nodeName = result.node.name {
//                return nodeName
//            }
//        }
//        return nil
//    }
//    
//    func displayModel(from url: URL) {
//        do {
//            let scene = try SCNScene(url: url)
//            
//            var modelName = getModelNameFromURL(modelURL!)
//            
//            if let modelNode = scene.rootNode.childNode(withName: modelName!, recursively: true) {
//                self.modelNode = modelNode
//                let lightNode = SCNNode()
//                lightNode.light = SCNLight()
//                lightNode.light?.type = .omni
//                lightNode.position = SCNVector3(x: 0, y: 10, z: 20)
//                scene.rootNode.addChildNode(lightNode)
//                
//                let ambientLightNode = SCNNode()
//                ambientLightNode.light = SCNLight()
//                ambientLightNode.light?.type = .ambient
//                ambientLightNode.light?.color = UIColor.darkGray
//                scene.rootNode.addChildNode(ambientLightNode)
//                
//                sceneViewSCN.scene = scene
//                sceneViewSCN.backgroundColor = UIColor.darkGray
//            } else {
//                print("Model node not found in the scene.")
//            }
//        } catch {
//            print("Error loading scene: \(error.localizedDescription)")
//        }
//    }
//}
