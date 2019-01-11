//
//  ViewController.swift
//  SmileTracker
//
//  Created by Shelley, Jake on 11/1/18.
//  Copyright © 2018 Shelley, Jake. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    let trackingView = ARSCNView()
    let smileLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check to make sure AR face tracking is supported
        guard ARFaceTrackingConfiguration.isSupported else {
            // If face tracking isn't available throw error and exit
            fatalError("ARKit is not supported on this device")
        }
        
        // Request camera permission
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
            if (granted) {
                // If access is granted, setup the main view
                DispatchQueue.main.sync {
                    self.setupSmileTracker()
                }
            } else {
                // If access is not granted, throw error and exit
                fatalError("This app needs Camera Access to function. You can grant access in Settings.")
            }
        }
    }
    
    func setupSmileTracker() {
        // Configure and start face tracking session
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        // Run ARSession and set delegate to self
        trackingView.session.run(configuration)
        trackingView.delegate = self
        
        // Add trackingView so that it will run
        view.addSubview(trackingView)
        
        // Add smileLabel to UI
        buildSmileLabel()
    }
    
    func buildSmileLabel() {
        smileLabel.text = "😐"
        smileLabel.font = UIFont.systemFont(ofSize: 150)
        
        view.addSubview(smileLabel)
        
        // Set constraints
        smileLabel.translatesAutoresizingMaskIntoConstraints = false
        smileLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        smileLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func handleSmile(smileValue: CGFloat) {
        switch smileValue {
        case _ where smileValue > 0.5:
            smileLabel.text = "😁"
        case _ where smileValue > 0.2:
            smileLabel.text = "🙂"
        default:
            smileLabel.text = "😐"
        }
    }
    
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Cast anchor as ARFaceAnchor
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        // Pull left/right smile coefficents from blendShapes
        let leftMouthSmileValue = faceAnchor.blendShapes[.mouthSmileLeft] as! CGFloat
        let rightMouthSmileValue = faceAnchor.blendShapes[.mouthSmileRight] as! CGFloat

        DispatchQueue.main.async {
            // Update label for new smile value
            self.handleSmile(smileValue: (leftMouthSmileValue + rightMouthSmileValue)/2.0)
        }
    }
    
}
