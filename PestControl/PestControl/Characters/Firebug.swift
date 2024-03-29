//
//  Firebug.swift
//  PestControl
//
//  Created by 马红奇 on 2018/12/2.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import SpriteKit

class Firebug: Bug {
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init() {
    super.init()
    name = "Firebug"
    color = .red
    colorBlendFactor = 0.8
    physicsBody?.categoryBitMask = PhysicsCategory.Firebug
  }
}
