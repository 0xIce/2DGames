//
//  GameScene.swift
//  CatNap
//
//  Created by 马红奇 on 2018/10/31.
//  Copyright © 2018 hotch. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol EventListenerNode {
  func didMoveToScene()
}

protocol InteractiveNode {
  func interact()
}

struct PhysicsCategory {
  static let None:    UInt32 = 0
  static let Cat:     UInt32 = 0b1
  static let Block:   UInt32 = 0b10
  static let Bed:     UInt32 = 0b100
  static let Edge:    UInt32 = 0b1000
  static let Label:   UInt32 = 0b10000
  static let Spring:  UInt32 = 0b100000
  static let Hook:    UInt32 = 0b1000000
}

class GameScene: SKScene {
  var bedNode: BedNode!
  var catNode: CatNode!
  
  var playable = true
  
  var currentLevel = 0
  
  var hookBaseNode: HookBaseNode?
  
  // MARK: - loop
  override func didMove(to view: SKView) {
    let maxAspectRatio: CGFloat = 16.0 / 9.0
    let maxAspectRatioHeight = size.width / maxAspectRatio
    let playableMargin: CGFloat = (size.height - maxAspectRatioHeight) / 2
    let playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: size.height - playableMargin * 2)
    
    physicsBody = SKPhysicsBody(edgeLoopFrom: playableRect)
    physicsWorld.contactDelegate = self
    physicsBody?.categoryBitMask = PhysicsCategory.Edge
    
    enumerateChildNodes(withName: "//*") { (node, _) in
      if let eventListenerNode = node as? EventListenerNode {
        eventListenerNode.didMoveToScene()
      }
    }
    
    bedNode = childNode(withName: "bed") as? BedNode
    catNode = childNode(withName: "//cat_body") as? CatNode
//    bedNode.setScale(1.5)
//    catNode.setScale(1.5)
    
    SKTAudio.sharedInstance().playBackgroundMusic("backgroundMusic.mp3")
    
//    let rotationConstraint = SKConstraint.zRotation(SKRange(lowerLimit: -π/4, upperLimit: π/4))
//    catNode.parent?.constraints = [rotationConstraint]
    
    hookBaseNode = childNode(withName: "hookBase") as? HookBaseNode
  }
  
  override func didSimulatePhysics() {
    guard playable,
      hookBaseNode?.isHooked != true else {
      return
    }
    if abs(catNode.parent!.zRotation) > CGFloat(25).degreesToRadians() {
      lose()
    }
  }
  
  // MARK: - action
  func inGameMessage(text: String) {
    let messageNode = MessageNode(message: text)
    messageNode.position = CGPoint(x: frame.midX, y: frame.midY)
    addChild(messageNode)
  }
  
  func newGame() {
//    let scene = SKScene(fileNamed: "GameScene")
    let scene = GameScene.level(levelNum: currentLevel)
    scene?.scaleMode = scaleMode
    view?.presentScene(scene) // remove current scene and replaces it with the new scene
  }
  
  func lose() {
    if currentLevel > 1 {
      currentLevel -= 1
    }
    playable = false
    SKTAudio.sharedInstance().pauseBackgroundMusic()
    SKTAudio.sharedInstance().playSoundEffect("lose.mp3")
    
    inGameMessage(text: "Try again...")
    
    run(SKAction.afterDelay(5, runBlock: newGame))
    catNode.wakeUp()
  }
  
  func win() {
    if currentLevel < 6 {
      currentLevel += 1
    }
    playable = false
    SKTAudio.sharedInstance().pauseBackgroundMusic()
    SKTAudio.sharedInstance().playSoundEffect("win.mp3")
    
    inGameMessage(text: "Nice job!")
    
    run(SKAction.afterDelay(3, runBlock: newGame))
    catNode.curlAt(scenePoint: bedNode.position)
  }
  
  // MARK: - helper
  class func level(levelNum: Int) -> GameScene? {
    let scene = GameScene(fileNamed: "Level\(levelNum)")
    scene?.currentLevel = levelNum
    scene?.scaleMode = .aspectFill
    return scene
  }
}

extension GameScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {
    let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    
    if collision == PhysicsCategory.Label | PhysicsCategory.Edge {
      let labelNode = contact.bodyA.categoryBitMask == PhysicsCategory.Label ? contact.bodyA.node : contact.bodyB.node
      (labelNode as! MessageNode).didBounce()
    }
    
    guard playable else {
      return
    }
    switch collision {
    case PhysicsCategory.Cat | PhysicsCategory.Bed:
      print("Success")
      win()
    case PhysicsCategory.Cat | PhysicsCategory.Edge:
      print("Fail")
      lose()
    case PhysicsCategory.Cat | PhysicsCategory.Hook where hookBaseNode?.isHooked == false:
      hookBaseNode?.hookCat(catPhysicsBody: catNode.parent!.physicsBody!)
    default:
      break
    }
  }
}
