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
  
  let zombieAnimation: SKAction
  let catCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
  let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
  
  var isZombieInvincible = false
  
  private lazy var zombie: SKSpriteNode = {
    let node = SKSpriteNode(imageNamed: "zombie1")
    return node
  }()
  
  override init(size: CGSize) {
    let maxAspectRatio: CGFloat = 16.0/9.0
    let playableHeight = size.width / maxAspectRatio
    let playableMargin = (size.height - playableHeight)/2.0
    playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
    
    var textures: [SKTexture] = []
    for i in 1...4 {
      textures.append(SKTexture(imageNamed: "zombie\(i)"))
    }
    textures.append(textures[2])
    textures.append(textures[1])
    zombieAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
    
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
//    zombie.run(SKAction.repeatForever(zombieAnimation))
//    spawnEnemy()
    run(SKAction.repeatForever(
      SKAction.sequence([SKAction.run({ [weak self] in
        self?.spawnEnemy()
        }),
                         SKAction.wait(forDuration: 2.0)])))
    
    run(SKAction.repeatForever(SKAction.sequence([SKAction.run { [weak self] in
      self?.spawnCat()
      },
                                                  SKAction.wait(forDuration: 1.0)])))
    
    debugDrawPlayableArea()
  }
  
  override func update(_ currentTime: TimeInterval) {
    calculate(currentTime)
    //    zombie.position = CGPoint(x: zombie.position.x + 8, y: zombie.position.y)
    //    move(sprite: zombie, velocity: CGPoint(x: zombieMovePointsPerSec, y: 0))
    if (lastTouchLocation - zombie.position).length <= zombieMovePointsPerSec * CGFloat(dt) {
      zombie.position = lastTouchLocation
      velocity = .zero
      stopZombieAnimation()
    } else {
      move(sprite: zombie, velocity: velocity)
      rotate(sprite: zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
    }
    boundsCheckZombie()
  }
  
  override func didEvaluateActions() {
    checkCollisions()
  }
  
  // MARK: - actions
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
    startZombieAnimation()
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
  
  /** test action
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
//    enemy.run(sequence)
    let repeatAction = SKAction.repeatForever(sequence)
    enemy.run(repeatAction)
  }
 */
  
  func spawnEnemy() {
    let enemy = SKSpriteNode(imageNamed: "enemy")
    enemy.name = "enemy"
    enemy.position = CGPoint(x: size.width + enemy.size.width/2,
                             y: CGFloat.random(min: playableRect.minY + enemy.size.height/2, max: playableRect.maxY - enemy.size.height/2))
    
    addChild(enemy)
    
    let actionMove = SKAction.moveTo(x: -enemy.size.width/2, duration: 2.0)
    let actionRemove = SKAction.removeFromParent()
    enemy.run(SKAction.sequence([actionMove, actionRemove]))
  }
  
  func spawnCat() {
    let cat = SKSpriteNode(imageNamed: "cat")
    cat.name = "cat"
    cat.position = CGPoint(x: CGFloat.random(min: playableRect.minX, max: playableRect.maxX), y: CGFloat.random(min: playableRect.minY, max: playableRect.maxY))
    cat.setScale(0)
    addChild(cat)
    
    let appear = SKAction.scale(to: 1.0, duration: 0.5)
//    let wait = SKAction.wait(forDuration: 10.0)
    cat.zRotation = -π / 16.0
    let leftWiggle = SKAction.rotate(byAngle: π/8.0, duration: 0.5)
    let rightWiggle = leftWiggle.reversed()
    let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
//    let wiggleWait = SKAction.repeat(fullWiggle, count: 10)
    let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
    let scaleDown = scaleUp.reversed()
    let fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
    let group = SKAction.group([fullScale, fullWiggle])
    let groupWait = SKAction.repeat(group, count: 10)
    
    let disappear = SKAction.scale(to: 0, duration: 0.5)
    let removeFromParent = SKAction.removeFromParent()
    let actions = [appear, groupWait, disappear, removeFromParent]
    cat.run(SKAction.sequence(actions))
  }
  
  func startZombieAnimation() {
    if zombie.action(forKey: "animation") == nil {
      zombie.run(SKAction.repeatForever(zombieAnimation), withKey: "animation")
    }
  }
  
  func stopZombieAnimation() {
    zombie.removeAction(forKey: "animation")
  }
  
  func zombieHit(cat: SKSpriteNode) {
    cat.removeFromParent()
//    run(SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false))
    run(catCollisionSound)
  }
  
  func zombieHit(enemy: SKSpriteNode) {
    enemy.removeFromParent()
    blinkZombie()
//    run(SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false))
    run(enemyCollisionSound)
  }
  
  func checkCollisions() {
    var hitCats: [SKSpriteNode] = []
    enumerateChildNodes(withName: "cat") { (node, _) in
      let cat = node as! SKSpriteNode
      if cat.frame.intersects(self.zombie.frame) {
        hitCats.append(cat)
      }
    }
    for cat in hitCats {
      zombieHit(cat: cat)
    }

    if isZombieInvincible {
      return
    }
    var hitEnemies: [SKSpriteNode] = []
    enumerateChildNodes(withName: "enemy") { (node, _) in
      let enemy = node as! SKSpriteNode
      if node.frame.insetBy(dx: 20, dy: 20).intersects(self.zombie.frame) {
        hitEnemies.append(enemy)
      }
    }
    for enemy in hitEnemies {
      zombieHit(enemy: enemy)
    }
  }
  
  func blinkZombie() {
    isZombieInvincible = true
    let blinkTimes = 10.0
    let duration = 3.0
    let blinkAction = SKAction.customAction(withDuration: duration) { (node, elapsedTime) in
      let slice = duration / blinkTimes
      let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
      node.isHidden = remainder > slice / 2
    }
    let setHidden = SKAction.run { [weak self] in
      self?.zombie.isHidden = false
      self?.isZombieInvincible = false
    }
    zombie.run(SKAction.sequence([blinkAction, setHidden]))
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
