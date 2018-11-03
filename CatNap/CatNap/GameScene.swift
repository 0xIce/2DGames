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
  static let None: UInt32 = 0
  static let Cat: UInt32 = 0b1
  static let Block: UInt32 = 0b10
  static let Bed: UInt32 = 0b100
  static let Edge: UInt32 = 0b1000
  static let Label: UInt32 = 0b10000
}

class GameScene: SKScene {
  var bedNode: BedNode!
  var catNode: CatNode!
  
  var playable = true
  
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
    
//    SKTAudio.sharedInstance().playBackgroundMusic("backgroundMusic.mp3")
  }
  
  func inGameMessage(text: String) {
    let messageNode = MessageNode(text: text)
    messageNode.position = CGPoint(x: frame.minX, y: frame.minY)
    addChild(messageNode)
  }
  
  func newGame() {
    let scene = SKScene(fileNamed: "GameScene")
    scene?.scaleMode = scaleMode
    view?.presentScene(scene) // remove current scene and replaces it with the new scene
  }
  
  func lose() {
    playable = false
    SKTAudio.sharedInstance().pauseBackgroundMusic()
    SKTAudio.sharedInstance().playSoundEffect("lose.mp3")
    
    inGameMessage(text: "Try again...")
    
    run(SKAction.afterDelay(5, runBlock: newGame))
    catNode.wakeUp()
  }
  
  func win() {
    playable = false
    SKTAudio.sharedInstance().pauseBackgroundMusic()
    SKTAudio.sharedInstance().playSoundEffect("win.mp3")
    
    inGameMessage(text: "Nice job!")
    
    run(SKAction.afterDelay(3, runBlock: newGame))
    catNode.curlAt(scenePoint: bedNode.position)
  }
}

extension GameScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {
    guard playable else {
      return
    }
    let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    switch collision {
    case PhysicsCategory.Cat | PhysicsCategory.Bed:
      print("Success")
      win()
    case PhysicsCategory.Cat | PhysicsCategory.Edge:
      print("Fail")
      lose()
    default:
      break
    }
  }
  
  func didEnd(_ contact: SKPhysicsContact) {
    
  }
}
