//
//  BlockNode.swift
//  CatNap
//
//  Created by 马红奇 on 2018/11/2.
//  Copyright © 2018 hotch. All rights reserved.
//

import SpriteKit

class BlockNode: SKSpriteNode {
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    print("destroy block")
    interact()
  }
}

extension BlockNode: EventListenerNode {
  func didMoveToScene() {
    isUserInteractionEnabled = true
  }
}

extension BlockNode: InteractiveNode {
  func interact() {
    isUserInteractionEnabled = false
    run(SKAction.sequence([SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false),
                           SKAction.scale(by: 0.8, duration: 0.1),
                           SKAction.removeFromParent()]))
  }
}
