//
//  Player.swift
//  PestControl
//
//  Created by 马红奇 on 2018/11/5.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import SpriteKit

enum PlayerSettings {
  static let playerSpeed: CGFloat = 280.0
}

class Player: SKSpriteNode {
  var animations: [SKAction] = []
  // MARK: - loop
  init() {
//    let texture = SKTexture(imageNamed: "player_ft1")
    let texture = SKTexture(pixelImageNamed: "player_ft1")
    super.init(texture: texture, color: .white, size: texture.size())
    name = "Player"
    zPosition = 50
    
    physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
    physicsBody?.restitution = 1.0
    physicsBody?.linearDamping = 0.5
    physicsBody?.friction = 0 // 光滑程度
    physicsBody?.allowsRotation = false
    
    createAnimations(charactar: "player")
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("Use init()")
  }
  
  // MARK: - action
  func move(target: CGPoint) {
    guard let physicsBody = physicsBody else {
      return
    }
    let newVelocity = (target - position).normalized() * PlayerSettings.playerSpeed
    physicsBody.velocity = CGVector(point: newVelocity)
    print("* \(animationDirection(for: physicsBody.velocity))")
    
    checkDirection()
  }
  
  func checkDirection() {
    guard let physicsBody = physicsBody else { return }
    
    let direction = animationDirection(for: physicsBody.velocity)
    
    switch direction {
    case .left:
      xScale = abs(xScale)
    case .right:
      xScale = -abs(xScale)
    default:
      break
    }
    
    run(animations[direction.rawValue], withKey: "animation")
  }
}

extension Player: Animatable {}
