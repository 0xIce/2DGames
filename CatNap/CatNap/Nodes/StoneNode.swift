//
//  StoneNode.swift
//  CatNap
//
//  Created by 马红奇 on 2018/11/4.
//  Copyright © 2018 hotch. All rights reserved.
//

import SpriteKit

class StoneNode: SKSpriteNode {
  static func makeCompoundNode(in scene: SKScene) -> SKNode {
    let compound = StoneNode()
    
    for stone in scene.children.filter({ (node) -> Bool in
      node is StoneNode
    }) {
      stone.removeFromParent()
      compound.addChild(stone)
    }
    
    let bodies = compound.children.map { (node) in
      SKPhysicsBody(rectangleOf: node.frame.size, center: node.position)
    }
    
    compound.physicsBody = SKPhysicsBody(bodies: bodies)
    compound.physicsBody?.categoryBitMask = PhysicsCategory.Block
    compound.physicsBody?.collisionBitMask = PhysicsCategory.Cat | PhysicsCategory.Edge | PhysicsCategory.Block
    compound.isUserInteractionEnabled = true
    compound.zPosition = 1
    
    return compound
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    interact()
  }
}

extension StoneNode: EventListenerNode {
  func didMoveToScene() {
    guard let scene = scene else {
      return
    }
    
    if parent == scene { // haven't moved to scene
      scene.addChild(StoneNode.makeCompoundNode(in: scene))
    }
  }
}

extension StoneNode: InteractiveNode {
  func interact() {
    isUserInteractionEnabled = false
    
    run(SKAction.sequence([SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false),
                           SKAction.removeFromParent()]))
  }
}
