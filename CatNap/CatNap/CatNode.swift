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
    physicsBody = SKPhysicsBody(texture: catBodyTexture, size: catBodyTexture.size())
  }
}
