//
//  Nodes.swift
//  AR-Portal
//
//  Created by Bjarne Lundgren on 02/07/2017.
//  Copyright © 2017 Silicon.dk ApS. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit
import AVFoundation

final class Nodes {
    static let WALL_WIDTH:CGFloat = 0.02
    static let WALL_HEIGHT:CGFloat = 2.2
    static let WALL_LENGTH:CGFloat = 1
    
    static let DOOR_HEIGHT:CGFloat = 0.6
    
    static let BUFFER:CGFloat = 0.01
    
    class func tubeNode(outer:CGFloat,
                                     height:CGFloat,
                                     openingRadius:CGFloat,
                                     maskOuterSide:Bool = true) -> SCNNode {
//      Tube Segment
        
        let segment = SCNTube(innerRadius: outer - Nodes.WALL_WIDTH,
                              outerRadius: outer,
                              height: height)
        
        segment.firstMaterial?.diffuse.contents = UIImage(named: "Media.scnassets/slipperystonework-albedo.png")
        segment.firstMaterial?.ambientOcclusion.contents = UIImage(named: "Media.scnassets/slipperystonework-ao.png")
        segment.firstMaterial?.metalness.contents = UIImage(named: "Media.scnassets/slipperystonework-metalness.png")
        segment.firstMaterial?.normal.contents = UIImage(named: "Media.scnassets/slipperystonework-normal.png")
        segment.firstMaterial?.roughness.contents = UIImage(named: "Media.scnassets/slipperystonework-rough.png")
        segment.firstMaterial?.writesToDepthBuffer = true
        segment.firstMaterial?.readsFromDepthBuffer = true
        
        let segmentNode = SCNNode(geometry: segment)
        segmentNode.renderingOrder = -1
        
        let maskSegment = SCNTube(innerRadius: outer,
                                  outerRadius: outer + Nodes.WALL_WIDTH,
                                  height: height)
        maskSegment.firstMaterial?.diffuse.contents = UIColor.red
        maskSegment.firstMaterial?.transparency = 0.000001
        maskSegment.firstMaterial?.writesToDepthBuffer = true
        
        let maskNode = SCNNode(geometry: maskSegment)
        maskNode.renderingOrder = -2
        
//      Bottom of Hole
        
        // A SpriteKit scene to contain the SpriteKit video node
        let spriteKitScene = SKScene(size: CGSize(width: 2160, height: 3840))
        spriteKitScene.scaleMode = .aspectFit

        // Create a video player, which will be responsible for the playback of the video material
//        let videoUrl = Bundle.main.url(forResource: "Media.scnassets/colab", withExtension: "mp4")!
//        let videoPlayer = AVPlayer(url: videoUrl)
        let streamUrl = URL(string: "https://video-edge-91412c.jfk03.hls.ttvnw.net/v0/CuwBiABal_mmfk6okExkUly0DuAYrVctf3U1zKfqKXfceowk_qOLDrxtFdaRgN8PAmQQRLdVABbEXaNpo4kaGd-jGV9t_DwrXW1qwy4hNq1Fy1KaLVCYBuRtc17jT897tPS31bdD8PIcwNfWDAfblFHb8YVrpvYuYYEe8dcJUgT9-Cq3w9xGCIaZvG8mKI_Z-_0GHWRlcw21TNGK_UF6HEVgCnnBaHv6rSyKwtI0HlOB3Q3sI-7gHb5oSogRLbnXT3pYcb-1j7mcQ7Bh1e_xqrvV4Sc6blMZYTDxBMw323GnFk3iBuFd7H-3PanQ7FISEOK1tHlvfd0EhlSndfG7TPoaDB6QNuMAHBvCm9ty6A/index-live.m3u8")
        let videoPlayer = AVPlayer(url: streamUrl!)
    
        // To make the video loop
        videoPlayer.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(Nodes.playerItemDidReachEnd),
            name:.AVPlayerItemDidPlayToEndTime,
            object: videoPlayer.currentItem)

        // Create the SpriteKit video node, containing the video player
        let videoSpriteKitNode = SKVideoNode(avPlayer: videoPlayer)
        videoSpriteKitNode.position = CGPoint(x: spriteKitScene.size.width / 2.0, y: spriteKitScene.size.height / 2.0)
        videoSpriteKitNode.size = spriteKitScene.size
        videoSpriteKitNode.yScale = -1.0
        videoSpriteKitNode.play()
        videoSpriteKitNode.name = "Video Player"
        spriteKitScene.addChild(videoSpriteKitNode)
        
        let holeBottomSegment = SCNCylinder(radius: outer, height: Nodes.WALL_WIDTH)
        holeBottomSegment.firstMaterial?.diffuse.contents = spriteKitScene
        holeBottomSegment.firstMaterial?.writesToDepthBuffer = true
        holeBottomSegment.firstMaterial?.readsFromDepthBuffer = true
        let holeBottomNode = SCNNode(geometry: holeBottomSegment)
        holeBottomNode.renderingOrder = -1
        
        
//      Opening of the Hole
        let openingSegment = SCNTube(innerRadius: openingRadius,
                                     outerRadius: outer,
                                     height: Nodes.BUFFER)
        openingSegment.firstMaterial?.diffuse.contents = UIImage(named: "Media.scnassets/slipperystonework-albedo.png")
        openingSegment.firstMaterial?.ambientOcclusion.contents = UIImage(named: "Media.scnassets/slipperystonework-ao.png")
        openingSegment.firstMaterial?.metalness.contents = UIImage(named: "Media.scnassets/slipperystonework-metalness.png")
        openingSegment.firstMaterial?.normal.contents = UIImage(named: "Media.scnassets/slipperystonework-normal.png")
        openingSegment.firstMaterial?.roughness.contents = UIImage(named: "Media.scnassets/slipperystonework-rough.png")
        openingSegment.firstMaterial?.writesToDepthBuffer = true
        openingSegment.firstMaterial?.readsFromDepthBuffer = true
        
        let openingNode = SCNNode(geometry: openingSegment)
        openingNode.renderingOrder = -1

        let maskOpeningSegment = SCNTube(innerRadius: openingRadius,
                                  outerRadius: outer + Nodes.WALL_WIDTH,
                                  height: Nodes.BUFFER)
        maskOpeningSegment.firstMaterial?.diffuse.contents = UIColor.red
        maskOpeningSegment.firstMaterial?.transparency = 0.000001
        maskOpeningSegment.firstMaterial?.writesToDepthBuffer = true
        
        let maskClosedSegment = SCNTube(innerRadius: 0.0001,
                                    outerRadius: outer + Nodes.WALL_WIDTH,
                                    height: Nodes.BUFFER)
        maskClosedSegment.firstMaterial?.diffuse.contents = UIColor.red
        maskClosedSegment.firstMaterial?.transparency = 0.000001
        maskOpeningSegment.firstMaterial?.writesToDepthBuffer = true

        let maskOpeningNode = SCNNode(geometry: maskClosedSegment)
        maskOpeningNode.renderingOrder = -2
        maskOpeningNode.morpher = SCNMorpher()
        maskOpeningNode.morpher?.targets = [maskOpeningSegment]
        maskOpeningNode.name = "holeOpening"
        maskOpeningNode.morpher?.setWeight(0.0, forTargetAt: 0)
        
//      The stuff inside the hole
        let objectGeometry = SCNSphere(radius: 0.025)
        objectGeometry.firstMaterial?.writesToDepthBuffer = true
        objectGeometry.firstMaterial?.readsFromDepthBuffer = true
        let objectNode = SCNNode(geometry: objectGeometry)
        objectNode.renderingOrder = -1
        
//      Putting the hole together
        let node = SCNNode()
        segmentNode.position = SCNVector3(0, 0, 0)
        node.addChildNode(segmentNode)
        maskNode.position = SCNVector3(0, 0, 0)
        node.addChildNode(maskNode)
        holeBottomNode.position = SCNVector3(0, (-height/2), 0)
        node.addChildNode(holeBottomNode)
        openingNode.position = SCNVector3(0, (height/2)-Nodes.WALL_WIDTH, 0)
        node.addChildNode(openingNode)
        maskOpeningNode.position = SCNVector3(0, height/2, 0)
        node.addChildNode(maskOpeningNode)
//        objectNode.position = SCNVector3(0.025,0,0)
//        node.addChildNode(objectNode)
        return node
    }
    
    // This callback will restart the video when it has reach its end
    @objc class func playerItemDidReachEnd(notification: NSNotification) {
        if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: kCMTimeZero, completionHandler: nil)
        }
    }
}
