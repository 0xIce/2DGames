//
//  BedNode.swift
//  CatNap
//
//  Created by 马红奇 on 2018/11/2.
//  Copyright © 2018 hotch. All rights reserved.
//

import SpriteKit

class BedNode: SKSpriteNode {
  
}

extension BedNode: EventListenerNode {
  func didMoveToScene() {
    physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 30))
    physicsBody?.isDynamic = false
  }
}
