import UIKit
import ARKit

// View controller for displaying 3D models in AR
class DisplayModelViewController: UIViewController, ARSCNViewDelegate {
    
    // Outlets
    @IBOutlet weak var sceneView: ARSCNView! // AR scene view
    
    // Properties
    var modelURL: URL? // URL of the 3D model to display
    var chairNode: SCNNode? // Node representing the 3D model
    var roomAnchor: ARAnchor? // Anchor for positioning the model in AR
    var modelName: String = "" // Name of the model
    
    // Transformation properties
    var scaleFactor: Float = 1.0
    var rotationX: Float = 0.0
    var rotationY: Float = 0.0
    var translationX: Float = 0.0
    var translationY: Float = 0.0
    
    
    // mark - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewTutorial()
        sceneView.delegate = self
        sceneView.isUserInteractionEnabled = true
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        let anchor = ARAnchor(transform: matrix_identity_float4x4)
        sceneView.session.add(anchor: anchor)
        roomAnchor = anchor
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        sceneView.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        sceneView.addGestureRecognizer(pinchGesture)
        
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        sceneView.addGestureRecognizer(rotateGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        sceneView.addGestureRecognizer(doubleTapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        sceneView.addGestureRecognizer(longPressGesture)
        
        if let modelURL = modelURL {
            initialModelName = getModelNameFromURL(modelURL)
        } else {
            print("No model URL provided.")
        }
        
        if let modelURL = modelURL {
            displayModel(from: modelURL)
        } else {
            print("No model URL provided.")
        }
    }
    
    //Setup
    
    func viewTutorial() {
        // Present tutorial view controller
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let displayModelVC = storyboard.instantiateViewController(withIdentifier: "TutorialARViewController") as? TutorialARViewController {
                let navigationController = UINavigationController(rootViewController: displayModelVC)
                    present(navigationController, animated: true, completion: nil)
            }
    }
    
    func setupSceneView() {
        sceneView.delegate = self
        sceneView.isUserInteractionEnabled = true
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        let anchor = ARAnchor(transform: matrix_identity_float4x4)
        sceneView.session.add(anchor: anchor)
        roomAnchor = anchor
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
    
    func setupGestureRecognizer() {
        // Setup gesture recognizers for interaction with the model
    }
    
    //Gesture Handling
    
    var initialModelName: String?
    
    
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        // Handle pinch gesture for scaling the model
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
        // Handle tap gesture
        let location = gesture.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        
        if let modelName = getModelName(fromTap: gesture) {
            print("Model name: \(modelName)")
            self.modelName = initialModelName ?? ""
        }
    }

    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        // Handle double tap gesture
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
        // Handle long press gesture
        if gesture.state == .began {
            let location = gesture.location(in: sceneView)
            let hitResults = sceneView.hitTest(location, options: nil)
            if let result = hitResults.first {
                let tappedNode = result.node
                print("Node tapped:- \(tappedNode)")
                if let geometry = tappedNode.geometry {
                    geometry.firstMaterial?.diffuse.contents = UIColor(.blue)
                    print(geometry.firstMaterial)
                }
            }
            
            if let result = hitResults.first {
                let tappedNode = result.node
                print("Node long pressed: \(tappedNode)")
            }
        }

    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        // Handle pan gesture for translating the model
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
        // Handle rotation gesture for rotating the model
        guard gesture.state == .changed else { return }
        guard let modelNode = sceneView.scene.rootNode.childNode(withName: modelName, recursively: true) else { return }
        modelNode.eulerAngles.y -= Float(gesture.rotation)
        gesture.rotation = 0
    }

    // Model Loading
    
    func loadModel() {
        guard let modelURL = modelURL else {
            print("No model URL provided.")
            return
        }
        
        do {
            let scene = try SCNScene(url: modelURL)
            addLights(to: scene)
            sceneView.scene = scene
            sceneView.backgroundColor = UIColor.black
        } catch {
            print("Error loading scene: \(error.localizedDescription)")
        }
    }
    
    func addLights(to scene: SCNScene) {
        // Add lights to the scene for better visualization
    }
    
    func displayModel(from url: URL) {
        do {
            let scene = try SCNScene(url: url)
            
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
        } catch {
            print("Error loading scene: \(error.localizedDescription)")
        }
    }
    
    
    //ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update node position and rotation based on anchor
        if anchor == roomAnchor, let chairNode = chairNode {
            let transform = SCNMatrix4(anchor.transform)
            let position = SCNVector3(transform.m41, transform.m42, transform.m43)
            let rotation = SCNVector4(transform.m11, transform.m12, transform.m13, transform.m14)
            chairNode.position = position
            chairNode.rotation = rotation
        }
    }
}
