//
//  GameScene.swift
//  ZombieConga
//
//  Created by 马红奇 on 2018/10/28.
//  Copyright © 2018 hotch. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
  var lastTouchLocation: CGPoint = .zero
  var lastUpdateTime: TimeInterval = 0
  var dt: TimeInterval = 0
  
  let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
  let zombieMovePointsPerSec: CGFloat = 480.0
  var velocity = CGPoint.zero
  
  let playableRect: CGRect
  
  private lazy var zombie: SKSpriteNode = {
    let node = SKSpriteNode(imageNamed: "zombie1")
    return node
  }()
  
  override init(size: CGSize) {
    let maxAspectRatio: CGFloat = 16.0/9.0
    let playableHeight = size.width / maxAspectRatio
    let playableMargin = (size.height - playableHeight)/2.0
    playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
    super.init(size: size)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMove(to view: SKView) {
    backgroundColor = .black
    let background = SKSpriteNode(imageNamed: "background1")
    background.zPosition = -1
    addChild(background)
    background.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
    
    zombie.position = CGPoint(x: 400, y: 400)
//    zombie.setScale(2.0)
    addChild(zombie)
    spawnEnemy()
    
    debugDrawPlayableArea()
  }
  
  // MARK: - actions
  override func update(_ currentTime: TimeInterval) {
    calculate(currentTime)
    //    zombie.position = CGPoint(x: zombie.position.x + 8, y: zombie.position.y)
    //    move(sprite: zombie, velocity: CGPoint(x: zombieMovePointsPerSec, y: 0))
    if (lastTouchLocation - zombie.position).length <= zombieMovePointsPerSec * CGFloat(dt) {
      zombie.position = lastTouchLocation
      velocity = .zero
    } else {
      move(sprite: zombie, velocity: velocity)
      rotate(sprite: zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
    }
    boundsCheckZombie()
  }
  
  func calculate(_ currentTime: TimeInterval) {
    if lastUpdateTime > 0 {
      dt = currentTime - lastUpdateTime
    } else {
      dt = 0
    }
    lastUpdateTime = currentTime
//    print("\(dt * 1000) milliseconds since lasst update")
  }
  
  func move(sprite: SKSpriteNode, velocity: CGPoint) {
    let amountToMove = velocity * CGFloat(dt)
//    print("Amount to move: \(amountToMove)")
    
    sprite.position += amountToMove
  }
  
  func move(sprite: SKSpriteNode, toward location: CGPoint) {
    let offset = location - sprite.position
    let direction = offset.normalized
    
    lastTouchLocation = location
    velocity = direction * zombieMovePointsPerSec
  }
  
  func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
    // angle1 是sprite的zRotation
    let shortestAngle = shortestAngleBetween(angle1: sprite.zRotation, angle2: direction.angle)
    let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortestAngle))
    // zRotation 是累加的
    sprite.zRotation += amountToRotate * shortestAngle.sign
  }
  
  func boundsCheckZombie() {
    let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
    let topRight = CGPoint(x: size.width, y: playableRect.maxY)
    
    if zombie.position.x <= bottomLeft.x {
      zombie.position.x = bottomLeft.x
      velocity.x = -velocity.x
    }
    
    if zombie.position.x >= topRight.x {
      zombie.position.x = topRight.x
      velocity.x = -velocity.x
    }
    
    if zombie.position.y <= bottomLeft.y {
      zombie.position.y = bottomLeft.y
      velocity.y = -velocity.y
    }
    
    if zombie.position.y >= topRight.y {
      zombie.position.y = topRight.y
      velocity.y = -velocity.y
    }
  }
  
  func spawnEnemy() {
    let enemy = SKSpriteNode(imageNamed: "enemy")
    enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: size.height/2)
    addChild(enemy)
    
//    let actionMidMove = SKAction.move(to: CGPoint(x: size.width/2, y: playableRect.minY + enemy.size.height/2), duration: 1.0)
    let actionMidMove = SKAction.moveBy(x: -size.width/2 - enemy.size.width/2, y: -playableRect.height/2 + enemy.size.height/2, duration: 1.0)
//    let actionMove = SKAction.move(to: CGPoint(x: -enemy.size.width/2, y: enemy.position.y), duration: 1.0)
    let actionMove = SKAction.moveBy(x: -size.width/2 - enemy.size.width/2, y: playableRect.height/2 - enemy.size.height/2, duration: 1.0)
    let wait = SKAction.wait(forDuration: 0.25)
    let logMessage = SKAction.run {
      print("Reached bottom!")
    }
    // sequence is reversible
    let sequence = SKAction.sequence([actionMidMove, logMessage, wait, actionMove, actionMove.reversed(), logMessage, wait, actionMidMove.reversed()])
    enemy.run(sequence)
  }
}


// MARK: - touches
extension GameScene {
  func sceneTouched(touchLocation: CGPoint) {
    move(sprite: zombie, toward: touchLocation)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    let touchLocation = touch.location(in: self)
    sceneTouched(touchLocation: touchLocation)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    
    let touchLocation = touch.location(in: self)
    sceneTouched(touchLocation: touchLocation)
  }
}

// MARK: - helper
extension GameScene {
  func debugDrawPlayableArea() {
    let shape = SKShapeNode(rect: playableRect)
    shape.strokeColor = SKColor.red
    shape.lineWidth = 4.0
    addChild(shape)
  }
}
