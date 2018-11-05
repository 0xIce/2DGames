//
//  Extensions.swift
//  PestControl
//
//  Created by 马红奇 on 2018/11/5.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import SpriteKit

extension SKTexture {
  convenience init(pixelImageNamed: String) {
    self.init(imageNamed: pixelImageNamed)
    filteringMode = .nearest
  }
}
