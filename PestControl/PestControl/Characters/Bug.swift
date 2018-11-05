//
//  Bug.swift
//  PestControl
//
//  Created by 马红奇 on 2018/11/5.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import SpriteKit

class Bug: SKSpriteNode {
  init() {
    let texture = SKTexture(pixelImageNamed: "bug_ft1")
    super.init(texture: texture, color: .white, size: texture.size())
    
    physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
    physicsBody?.allowsRotation = false
    physicsBody?.restitution = 0.5
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
