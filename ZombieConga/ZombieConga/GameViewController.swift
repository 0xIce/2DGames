//
//  GameViewController.swift
//  ZombieConga
//
//  Created by 马红奇 on 2018/10/28.
//  Copyright © 2018 hotch. All rights reserved.
//

import SpriteKit

class GameViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    let skView = self.view as! SKView
    skView.showsFPS = true
    skView.showsNodeCount = true
    skView.ignoresSiblingOrder = true
    
    let menuScene = MainMenuScene(size: CGSize(width: 2048, height: 1536))
    let doorWay = SKTransition.doorway(withDuration: 1.5)
    skView.presentScene(menuScene, transition: doorWay)
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
}
