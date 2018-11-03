//
//  MessageNode.swift
//  CatNap
//
//  Created by 马红奇 on 2018/11/3.
//  Copyright © 2018 hotch. All rights reserved.
//

import SpriteKit

class MessageNode: SKLabelNode {
  convenience init(message: String) {
    self.init(fontNamed: "AvenirNext-Regular")
    
    text = message
    fontSize = 256.0
    fontColor = .gray
    zPosition = 100
    
    let front = SKLabelNode(fontNamed: "AvenirNext-Regular")
    front.text = message
    front.fontSize = 256.0
    front.fontColor = .white
    front.position = CGPoint(x: -2, y: -2)
    addChild(front)
    
    physicsBody = SKPhysicsBody(circleOfRadius: 10)
    physicsBody?.categoryBitMask = PhysicsCategory.Label
    physicsBody?.collisionBitMask = PhysicsCategory.Edge
    physicsBody?.restitution = 0.7
  }
}
