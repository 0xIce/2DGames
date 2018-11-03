//
//  CatNode.swift
//  CatNap
//
//  Created by 马红奇 on 2018/11/2.
//  Copyright © 2018 hotch. All rights reserved.
//

import SpriteKit

class CatNode: SKSpriteNode {
  
}

extension CatNode: EventListenerNode {
  func didMoveToScene() {
    let catBodyTexture = SKTexture(imageNamed: "cat_body_outline")
    parent?.physicsBody = SKPhysicsBody(texture: catBodyTexture, size: catBodyTexture.size())
    
    parent?.physicsBody?.categoryBitMask = PhysicsCategory.Cat
    parent?.physicsBody?.collisionBitMask = PhysicsCategory.Block | PhysicsCategory.Edge
    parent?.physicsBody?.contactTestBitMask = PhysicsCategory.Bed | PhysicsCategory.Edge
  }
  
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
}
