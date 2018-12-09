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
  var hasBugspray: Bool = false {
    didSet {
      blink(color: .green, on: hasBugspray)
    }
  }
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
    
    physicsBody?.categoryBitMask = PhysicsCategory.Player
    physicsBody?.contactTestBitMask = PhysicsCategory.All
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    animations = aDecoder.decodeObject(forKey: "Player.animations") as! [SKAction]
    hasBugspray = aDecoder.decodeBool(forKey: "Player.hasBugspray")
    if hasBugspray {
      removeAction(forKey: "blink")
      blink(color: .green, on: hasBugspray)
    }
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
  
  func blink(color: SKColor, on: Bool) {
    // 1
    let blinkOff = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.2)
    if on {
      let blinkOn = SKAction.colorize(with: color,
                                      colorBlendFactor: 1.0,
                                      duration: 0.2)
      let blink = SKAction.repeatForever(SKAction.sequence([blinkOn, blinkOff]))
      xScale = xScale < 0 ? -1.5 : 1.5
      yScale = 1.5
      run(blink, withKey: "blink")
    } else {
      xScale = xScale < 0 ? -1.0 : 1.0
      yScale = 1.0
      removeAction(forKey: "blink")
      run(blinkOff)
    }
  }
}

extension Player: Animatable {}

// MARk: - Save Game
extension Player {
  override func encode(with aCoder: NSCoder) {
    aCoder.encode(hasBugspray, forKey: "Player.hasBugspray")
    aCoder.encode(animations, forKey: "Player.animations")
    super.encode(with: aCoder) }
}
