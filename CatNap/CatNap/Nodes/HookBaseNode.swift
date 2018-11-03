//
//  HookBaseNode.swift
//  CatNap
//
//  Created by 马红奇 on 2018/11/3.
//  Copyright © 2018 hotch. All rights reserved.
//

import SpriteKit

class HookBaseNode: SKSpriteNode {
  private var ropeNode = SKSpriteNode(imageNamed: "rope")
  private var hookNode = SKSpriteNode(imageNamed: "hook")
  private var hookJoint: SKPhysicsJointFixed?
  
  var isHooked: Bool {
    return hookJoint != nil
  }
}


extension HookBaseNode: EventListenerNode {
  func didMoveToScene() {
    guard let scene = scene else {
      return
    }
    
    let ceilingFix = SKPhysicsJointFixed.joint(withBodyA: scene.physicsBody!, bodyB: physicsBody!, anchor: .zero)
    scene.physicsWorld.add(ceilingFix)
    
    ropeNode.anchorPoint = CGPoint(x: 0, y: 0.5)
    ropeNode.zRotation = CGFloat(270).degreesToRadians()
    ropeNode.position = position
    scene.addChild(ropeNode)
    
    hookNode.position = CGPoint(x: position.x, y: position.y - ropeNode.size.width)
    hookNode.physicsBody = SKPhysicsBody(circleOfRadius: hookNode.size.width / 2)
    hookNode.physicsBody?.categoryBitMask = PhysicsCategory.Hook
    hookNode.physicsBody?.collisionBitMask = PhysicsCategory.None
    hookNode.physicsBody?.contactTestBitMask = PhysicsCategory.Cat
    scene.addChild(hookNode)
    
    let hookPosition = CGPoint(x: hookNode.position.x, y: hookNode.position.y + hookNode.size.height / 2)
    let ropeJoint = SKPhysicsJointSpring.joint(withBodyA: physicsBody!, bodyB: hookNode.physicsBody!, anchorA: position, anchorB: hookPosition)
    scene.physicsWorld.add(ropeJoint)
  }
}
