//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by 马红奇 on 2018/10/31.
//  Copyright © 2018 hotch. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
  
  override func didMove(to view: SKView) {
    let background = SKSpriteNode(imageNamed: "MainMenu")
    background.position = CGPoint(x: size.width/2, y: size.height/2)
    addChild(background)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    sceneTapped()
  }
  
  func sceneTapped() {
    let scene = GameScene(size: size)
    scene.scaleMode = .aspectFill
    view?.presentScene(scene)
  }
}
