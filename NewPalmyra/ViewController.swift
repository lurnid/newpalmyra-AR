//
//  ViewController.swift
//  NewPalmyra
//
//  Created by Mahmoud Wardeh on 21/09/2018.
//  Copyright © 2018 Visiva Ltd. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    var nodeModel:SCNNode!
    let nodeName = "arch-of-triumph"
    
    @IBOutlet weak var scaleSlider: UISlider! {
        //make it vertical
        didSet {
            scaleSlider.transform =  CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        //sceneView.debugOptions = ARSCNDebugOptions.showWorldOrigin
//        sceneView.antialiasingMode = .multisampling4X

        // Create a new scene
        let scene = SCNScene()
        // Set the scene to the view
        sceneView.scene = scene
        let modelScene = SCNScene(named: "art.scnassets/arch-of-triumph.scn")!
        nodeModel = modelScene.rootNode.childNode(withName: nodeName, recursively: true)
        configureLighting()
        configureSlider()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: sceneView)
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        let hitResults: [SCNHitTestResult] =
            sceneView.hitTest(location, options: hitTestOptions)
        if let hit = hitResults.first {
            if let node = getParent(hit.node) {
                node.removeFromParentNode()
                return
            }
        }
        
        let hitResultsFeaturePoints: [ARHitTestResult] =
            sceneView.hitTest(location, types: .featurePoint)
        if let hit = hitResultsFeaturePoints.first {
            sceneView.session.add(anchor: ARAnchor(transform: hit.worldTransform))
        }
    }
    
    func getParent(_ nodeFound: SCNNode?) -> SCNNode? {
        if let node = nodeFound {
            if node.name == nodeName {
                return node
            } else if let parent = node.parent {
                return getParent(parent)
            }
        }
        return nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
        
        sceneView.delegate = self
    }

    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    func configureSlider() {
        // Add an scaleSlider button
        scaleSlider.addTarget(self, action: #selector(updateScaleWithSlider(_:)), for: .touchUpInside)
        scaleSlider.minimumValue = 0.02
        scaleSlider.maximumValue = 1.5
        // add scaleSlider to view
        sceneView.addSubview(scaleSlider)
        
        // Auto Layout
        scaleSlider.translatesAutoresizingMaskIntoConstraints = true
    }

    func scaleNode(value: Float) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1
        nodeModel.scale = SCNVector3(value, value, value)
        SCNTransaction.commit()
    }
    
    @IBAction func updateScaleWithSlider(_ sender: UISlider) {
        guard let slider = sender as? UISlider else { return }
        scaleNode(value: slider.value)
    }

    func showModel(_ node: SCNNode) {
//        let modelClone = self.nodeModel.clone()
        nodeModel.position = SCNVector3Zero

        // Add model as a child to the node
        node.addChildNode(nodeModel)
        self.scaleNode(value: scaleSlider.value)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

extension UIColor {
    open class var transparentNewPalmyraOrange: UIColor {
        return UIColor(red: 196/255, green: 93/255, blue: 36/255, alpha: 0.50)
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Display detected planes
        if !anchor.isKind(of: ARPlaneAnchor.self) {
            DispatchQueue.main.async {
                self.showModel(node)
            }
        }
    }
}
