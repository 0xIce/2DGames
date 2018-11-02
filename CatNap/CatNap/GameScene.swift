//
//  GameScene.swift
//  CatNap
//
//  Created by 马红奇 on 2018/10/31.
//  Copyright © 2018 hotch. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol EventListenerNode {
  func didMoveToScene()
}

protocol InteractiveNode {
  func interact()
}

struct PhysicsCategory {
  static let None: UInt32 = 0
  static let Cat: UInt32 = 0b1
  static let Block: UInt32 = 0b10
  static let Bed: UInt32 = 0b100
}

class GameScene: SKScene {
  var bedNode: BedNode!
  var catNode: CatNode!
  
  override func didMove(to view: SKView) {
    let maxAspectRatio: CGFloat = 16.0 / 9.0
    let maxAspectRatioHeight = size.width / maxAspectRatio
    let playableMargin: CGFloat = (size.height - maxAspectRatioHeight) / 2
    let playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: size.height - playableMargin * 2)
    
    physicsBody = SKPhysicsBody(edgeLoopFrom: playableRect)
    
    enumerateChildNodes(withName: "//*") { (node, _) in
      if let eventListenerNode = node as? EventListenerNode {
        eventListenerNode.didMoveToScene()
      }
    }
    
    bedNode = childNode(withName: "bed") as! BedNode
    catNode = childNode(withName: "//cat_body") as! CatNode
//    bedNode.setScale(1.5)
//    catNode.setScale(1.5)
    
//    SKTAudio.sharedInstance().playBackgroundMusic("backgroundMusic.mp3")
  }
}
