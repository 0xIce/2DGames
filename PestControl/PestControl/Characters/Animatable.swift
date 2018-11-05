//
//  Animatable.swift
//  PestControl
//
//  Created by 马红奇 on 2018/11/5.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import SpriteKit

protocol Animatable: class {
  var animations: [SKAction] { get set }
}

extension Animatable {
  func animationDirection(for directionVector: CGVector) -> Direction {
    let direction: Direction
    if abs(directionVector.dy) > abs(directionVector.dx) {
      direction = directionVector.dy < 0 ? .forward : .backward
    } else {
      direction = directionVector.dx < 0 ? .left : .right
    }
    return direction
  }
  
  func createAnimations(charactar: String) {
    let actionForward = SKAction.animate(with: [SKTexture(pixelImageNamed: "\(charactar)_ft1"),
                                                SKTexture(pixelImageNamed: "\(charactar)_ft2")], timePerFrame: 0.2)
    animations.append(SKAction.repeatForever(actionForward))
    
    let actionBackward = SKAction.animate(with: [SKTexture(pixelImageNamed: "\(charactar)_bk1"),
                                                 SKTexture(pixelImageNamed: "\(charactar)_bk2")], timePerFrame: 0.2)
    animations.append(SKAction.repeatForever(actionBackward))
    
    let actionLeft = SKAction.animate(with: [SKTexture(pixelImageNamed: "\(charactar)_lt1"),
                                             SKTexture(pixelImageNamed: "\(charactar)_lt2")], timePerFrame: 0.2)
    animations.append(SKAction.repeatForever(actionLeft))
    
    animations.append(SKAction.repeatForever(actionLeft))
    
  }
}

