//
//  SpringNode.swift
//  CatNap
//
//  Created by 马红奇 on 2018/11/3.
//  Copyright © 2018 hotch. All rights reserved.
//

import SpriteKit

class SpringNode: SKSpriteNode {
  
  // MARK:- actions
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    interact()
  }
}

extension SpringNode: EventListenerNode {
  func didMoveToScene() {
    isUserInteractionEnabled = true
  }
}

extension SpringNode: InteractiveNode {
  func interact() {
    isUserInteractionEnabled = false
    
    physicsBody?.applyImpulse(CGVector(dx: 0, dy: 250), at: CGPoint(x: size.width / 2, y: size.height))
    
    run(SKAction.sequence([SKAction.wait(forDuration: 1),
                           SKAction.removeFromParent()]))
  }
}
