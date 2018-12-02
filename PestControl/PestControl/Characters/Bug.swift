//
//  Bug.swift
//  PestControl
//
//  Created by 马红奇 on 2018/11/5.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import SpriteKit

enum BugSettings {
  static let bugDistance: CGFloat = 16
}

class Bug: SKSpriteNode {
  var animations: [SKAction] = []
  init() {
    let texture = SKTexture(pixelImageNamed: "bug_ft1")
    super.init(texture: texture, color: .white, size: texture.size())
    
    physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
    physicsBody?.allowsRotation = false
    physicsBody?.restitution = 0.5
    
    createAnimations(charactar: "bug")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func move() {
    // 1
    let randomX = CGFloat(Int.random(min: -1, max: 1))
    let randomY = CGFloat(Int.random(min: -1, max: 1))
    
    let vector = CGVector(dx: randomX * BugSettings.bugDistance,
                          dy: randomY * BugSettings.bugDistance)
    // 2
    let moveBy = SKAction.move(by: vector, duration: 1)
    let moveAgain = SKAction.run(move)
    
    // 3.1
    let direction = animationDirection(for: vector)
    // 3.2
    switch direction {
    case .left:
      xScale = abs(xScale)
    case .right:
      xScale = -abs(xScale)
    default:
      break
    }
    // 3.3
    run(animations[direction.rawValue], withKey: "animation")
    run(SKAction.sequence([moveBy, moveAgain]))
  }
}

extension Bug: Animatable {}
