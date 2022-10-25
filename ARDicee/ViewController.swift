//
//  ViewController.swift
//  ARDicee
//
//  Created by Vlad V on 22.10.2022.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        //sceneView.showsStatistics = true
        
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    //MARK: - Dice Rendering Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: sceneView)
            guard let query = sceneView.raycastQuery(from: location, allowing: .existingPlaneGeometry, alignment: .any) else {
                return
            }
            let results = sceneView.session.raycast(query)
            if let hitResult = results.first {
                print(hitResult)
                
                let position = SCNVector3(
                    x: hitResult.worldTransform.columns.3.x,
                    y: hitResult.worldTransform.columns.3.y,
                    z: hitResult.worldTransform.columns.3.z)
                
                spawnDice(position)
            }
        }
    }
    
    func spawnDice(_ position : SCNVector3){
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")
        
        if let diceNode = diceScene?.rootNode.childNode(withName: "Dice", recursively: true){
            diceNode.position = position
            
            roll(diceNode)
            
            diceArray.append(diceNode)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
        }
    }
    
    func roll(_ dice : SCNNode){
        let randomX = Float(Int.random(in: 1 ... 5)) * (Float.pi/2)
        let randomZ = Float(Int.random(in: 1 ... 5)) * (Float.pi/2)
        
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX) * 5, y: 0, z: CGFloat(randomZ) * 5, duration: 0.5))
        
    }
    
    func rollAll(){
        if !diceArray.isEmpty{
            for dice in diceArray{
                roll(dice)
            }
        }
    }
    
    
    @IBAction func rollAgain(_ sender: Any) {
        rollAll()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    
    @IBAction func removeAllDices(_ sender: Any) {
        if !diceArray.isEmpty {
            for dice in diceArray{
                dice.removeFromParentNode()
            }
        }
    }
    
    //MARK: - ARSCNViewDelegateMethods
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        node.addChildNode(planeNode)
    }
    
    //MARK: - Plane rendering
    
    func createPlane(withPlaneAnchor planeAnchor : ARPlaneAnchor) -> SCNNode{
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.planeExtent.width), height: CGFloat(planeAnchor.planeExtent.height))

        let planeNode = SCNNode()
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)

        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")

        plane.materials = [gridMaterial]

        planeNode.geometry = plane

        return planeNode
    }
}
