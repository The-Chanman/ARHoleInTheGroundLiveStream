//
//  ViewController.swift
//  AR-Portal
//
//  Created by Bjarne Lundgren on 02/07/2017.
//  Copyright © 2017 Silicon.dk ApS. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    @IBOutlet weak var planeSearchLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    var detectedDataAnchor: ARAnchor?
    var processing = false
    var foundMarkerForHole = false
    var holeOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = false
        self.planeSearchLabel.text = "Searching for wormholes near you!"
        sceneView.isPlaying = true
        
//      Show basically activity monitor for ios apps
        sceneView.showsStatistics = true
        
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
//        updatePlaneOverlay()
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(didTap))
        sceneView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    @objc func didTap(_ sender:UITapGestureRecognizer) {
//        let location = sender.location(in: sceneView)
//
//        print("didTap \(location)")
//
//        guard currentPlane == nil,
//              let newPlaneData = anyPlaneFrom(location: location) else { return }
//
//        print("adding wall???")
//        currentPlane = newPlaneData.0
//
//        let wallNode = SCNNode()
//        wallNode.position = newPlaneData.1
//
//        let holeRadius:CGFloat = 2
//        let openingRadius:CGFloat = 0.5
//        let holeHeight:CGFloat = 2.5
//
//        let holeWallsNode = Nodes.tubeNode(outer: holeRadius,
//                                                           height: holeHeight,
//                                                           openingRadius: openingRadius,
//                                                           maskOuterSide: true)
//        holeWallsNode.eulerAngles = SCNVector3(0, 0, 0)
//        holeWallsNode.position = SCNVector3(0,-holeHeight*0.5,0)
        
//      hole opening animation
        if !self.holeOpen {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.0
            self.sceneView.scene.rootNode.childNode(withName: "holeOpening", recursively: true)?.morpher?.setWeight(0.0, forTargetAt: 0) // From closed to open
            
            SCNTransaction.completionBlock = {
                NSLog("Transaction completing")
                SCNTransaction.begin()
                SCNTransaction.animationDuration  = 5.0
                self.sceneView.scene.rootNode.childNode(withName: "holeOpening", recursively: true)?.morpher?.setWeight(1, forTargetAt: 0) // And back
                SCNTransaction.commit()
            }
            SCNTransaction.commit()
            self.holeOpen = true
        }


////      Adding the hole to the scene
//        wallNode.addChildNode(holeWallsNode)
//
//        let currentPosition = wallNode.position
//        print(currentPosition)
//
//        sceneView.scene.rootNode.addChildNode(wallNode)
//
//        // we would like shadows from inside the portal room to shine onto the floor of the camera image(!)
//        let floor = SCNFloor()
//        floor.reflectivity = 0
//        floor.firstMaterial?.diffuse.contents = UIColor.white
//        floor.firstMaterial?.colorBufferWriteMask = SCNColorMask(rawValue: 0)
//        let floorShadowNode = SCNNode(geometry:floor)
//        floorShadowNode.position = newPlaneData.1
//        sceneView.scene.rootNode.addChildNode(floorShadowNode)
//
//        let light = SCNLight()
//        // [SceneKit] Error: shadows are only supported by spot lights and directional lights
//        light.type = .spot
//        light.spotInnerAngle = 70
//        light.spotOuterAngle = 120
//        light.zNear = 0.00001
//        light.zFar = 5
//        light.castsShadow = true
//        light.shadowRadius = 200
//        light.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
//        light.shadowMode = .deferred
//        let constraint = SCNLookAtConstraint(target: floorShadowNode)
//        constraint.isGimbalLockEnabled = true
//        let lightNode = SCNNode()
//        lightNode.light = light
//        lightNode.position = SCNVector3(newPlaneData.1.x,
//                                        newPlaneData.1.y + Float(Nodes.DOOR_HEIGHT),
//                                        newPlaneData.1.z - Float(Nodes.WALL_LENGTH))
//        lightNode.constraints = [constraint]
//        sceneView.scene.rootNode.addChildNode(lightNode)
    }
    
    // this func from Apple ARKit placing objects demo
    func enableEnvironmentMapWithIntensity(_ intensity: CGFloat) {
        if sceneView.scene.lightingEnvironment.contents == nil {
            if let environmentMap = UIImage(named: "Media.scnassets/environment_blur.exr") {
                sceneView.scene.lightingEnvironment.contents = environmentMap
            }
        }
        sceneView.scene.lightingEnvironment.intensity = intensity
    }
    
    /// MARK: - ARSCNViewDelegate
    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if self.processing {
            return
        }
        
        self.processing = true
        if !foundMarkerForHole {
            let request = VNDetectBarcodesRequest { (request, error) in
                if let results = request.results, let result = results.first as? VNBarcodeObservation {
                    var boundingBox = result.boundingBox
                    
                    boundingBox = boundingBox.applying(CGAffineTransform(scaleX: 1, y: -1))
                    boundingBox = boundingBox.applying(CGAffineTransform(translationX: 0, y: 1))
                    
                    let markerCenter = CGPoint(x: boundingBox.midX, y: boundingBox.midY)
                    
                    DispatchQueue.main.async {
                        let hitTestResults = frame.hitTest(markerCenter, types: [.featurePoint])
                        
                        if let hitTestResult = hitTestResults.first {
                            
                            if let detectedDataAnchor = self.detectedDataAnchor,
                                let node = self.sceneView.node(for: detectedDataAnchor) {
                                
                                node.transform = SCNMatrix4(hitTestResult.worldTransform)
                                print("found the marker the second time.")
                                
                            } else {
                                // Create an anchor. The node will be created in delegate methods
                                if !self.foundMarkerForHole {
                                    self.detectedDataAnchor = ARAnchor(transform: hitTestResult.worldTransform)
                                    self.sceneView.session.add(anchor: self.detectedDataAnchor!)
                                    self.foundMarkerForHole = true
                                    self.planeSearchLabel.text = "Located wormhole please tap to tune into the frequency."
                                    print("found the marker for the first time")
                                }
                            }
                        }
                        self.processing = false
                    }
                } else {
                    self.processing = false
                }
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    request.symbologies = [.QR]
                    // Create a request handler using the captured image from the ARFrame
                    let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage,
                                                                    options: [:])
                    // Process the request
                    try imageRequestHandler.perform([request])
                } catch {
                    
                }
            }
        }
        
    }
    
    // this func from Apple ARKit placing objects demo
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // from apples app
        DispatchQueue.main.async {
            // If light estimation is enabled, update the intensity of the model's lights and the environment map
            if let lightEstimate = self.sceneView.session.currentFrame?.lightEstimate {
                self.enableEnvironmentMapWithIntensity(lightEstimate.ambientIntensity / 50)
            } else {
                self.enableEnvironmentMapWithIntensity(25)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        // If this is our anchor, create a node
        if self.detectedDataAnchor?.identifier == anchor.identifier {
            
            let wrapperNode = SCNNode()
            
            let holeRadius:CGFloat = 2.5
            let openingRadius:CGFloat = 0.25
            let holeHeight:CGFloat = 2.5
            
            let holeWallsNode = Nodes.tubeNode(outer: holeRadius, height: holeHeight, openingRadius: openingRadius, maskOuterSide: true)
            holeWallsNode.eulerAngles = SCNVector3(0, 0, 0)
            holeWallsNode.position = SCNVector3(0,-holeHeight*0.5,0)
            
            //      Adding the hole to the scene
            wrapperNode.addChildNode(holeWallsNode)
            
//            set the position based of the AR anchor
            wrapperNode.transform = SCNMatrix4(anchor.transform)
            wrapperNode.eulerAngles = SCNVector3Make(0, 0, Float.pi/2)
//            sceneView.scene.rootNode.addChildNode(wrapperNode)
            
            return wrapperNode
        }
        
        return nil
    }
}

