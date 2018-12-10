//
//  GameScene.swift
//  DropCharge
//
//  Created by 马红奇 on 2018/12/10.
//  Copyright © 2018 hongqima. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
  var bgNode: SKNode!
  var fgNode: SKNode!
  var backgroundOverlayTemplate: SKNode!
  var backgroundOverlayHeight: CGFloat!
  var player: SKSpriteNode!
  
  var platform5Across: SKSpriteNode!
  var coinArrow: SKSpriteNode!
  var lastOverlayPosition = CGPoint.zero
  var lastOverlayHeight: CGFloat = 0.0
  var levelPositionY: CGFloat = 0.0
  
  override func didMove(to view: SKView) {
    setupNodes()
  }
  
  func setupNodes() {
    let worldNode = childNode(withName: "World")!
    bgNode = worldNode.childNode(withName: "Background")!
    backgroundOverlayTemplate = bgNode.childNode(withName: "Overlay")!.copy() as! SKNode
    backgroundOverlayHeight = backgroundOverlayTemplate.calculateAccumulatedFrame().height
    fgNode = worldNode.childNode(withName: "Foreground")!
    player = fgNode.childNode(withName: "Player") as! SKSpriteNode
    fgNode.childNode(withName: "Bomb")?.run(SKAction.hide())
  }
  
  // MARK: - Overlay nodes
  func loadForgroundOverlayTemplate(_ fileName: String) -> SKSpriteNode {
    let overlayScene = SKScene(fileNamed: fileName)!
    let overlayTemplate = overlayScene.childNode(withName: "Overlay") as! SKSpriteNode
    return overlayTemplate
  }
  
  func createForegroundOverlay(_ overlayTemplate: SKSpriteNode, flipX: Bool) {
    let foregroundOverlay = overlayTemplate.copy() as! SKSpriteNode
    lastOverlayPosition.y = lastOverlayPosition.y + (lastOverlayHeight + (foregroundOverlay.size.height / 2.0))
    lastOverlayHeight = foregroundOverlay.size.height / 2.0
    foregroundOverlay.position = lastOverlayPosition
    if flipX == true {
      foregroundOverlay.xScale = -1.0
    }
    fgNode.addChild(foregroundOverlay)
  }
  
  func createBackgroundOverlay() {
    let backgroundOverlay = backgroundOverlayTemplate.copy() as! SKNode
    backgroundOverlay.position = CGPoint(x: 0.0, y: levelPositionY)
    bgNode.addChild(backgroundOverlay)
    levelPositionY += backgroundOverlayHeight
  }
}
