//
//  CatNode.swift
//  CatNap
//
//  Created by 马红奇 on 2018/11/2.
//  Copyright © 2018 hotch. All rights reserved.
//

import SpriteKit

class CatNode: SKSpriteNode {
  static let kCatTappedNotification = "kCatTappedNotification"

  func wakeUp() {
    for child in children {
      child.removeFromParent()
    }
    texture = nil
    color = .clear
    
    let catWakeUp = SKSpriteNode(fileNamed: "CatWakeUp")?.childNode(withName: "cat_awake")
    // remove it from current parent and add it here, cant use addChild when a node already has a parent
    catWakeUp?.move(toParent: self)
    catWakeUp?.position = CGPoint(x: -30, y: 100)
  }
  
  func curlAt(scenePoint: CGPoint) {
    parent?.physicsBody = nil
    for child in children {
      child.removeFromParent()
    }
    texture = nil
    color = .clear
    
    let catCurl = SKSpriteNode(fileNamed: "CatCurl")?.childNode(withName: "cat_curl")
    // the order move and position cant be reverted
    catCurl?.move(toParent: self)
    catCurl?.position = CGPoint(x: -30, y: 100)
    
    var localPoint = parent!.convert(scenePoint, from: scene!)
    localPoint.y += frame.size.height / 3
    
    run(SKAction.group([SKAction.move(to: localPoint, duration: 0.66),
                        SKAction.rotate(toAngle: -parent!.zRotation, duration: 0.5)]))
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    interact()
  }
}

extension CatNode: EventListenerNode {
  func didMoveToScene() {
    isUserInteractionEnabled = true
    
    let catBodyTexture = SKTexture(imageNamed: "cat_body_outline")
    parent?.physicsBody = SKPhysicsBody(texture: catBodyTexture, size: catBodyTexture.size())
    
    parent?.physicsBody?.categoryBitMask = PhysicsCategory.Cat
    parent?.physicsBody?.collisionBitMask = PhysicsCategory.Block | PhysicsCategory.Edge | PhysicsCategory.Spring
    parent?.physicsBody?.contactTestBitMask = PhysicsCategory.Bed | PhysicsCategory.Edge
  }
}

extension CatNode: InteractiveNode {
  func interact() {
    NotificationCenter.default.post(name: NSNotification.Name(CatNode.kCatTappedNotification), object: nil)
  }
}
