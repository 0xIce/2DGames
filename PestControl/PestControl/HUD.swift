//
//  HUD.swift
//  PestControl
//
//  Created by 马红奇 on 2018/12/8.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import SpriteKit

enum HUDSettings {
  static let font = "Noteworthy-Bold"
  static let fontSize: CGFloat = 50
}

class HUD: SKNode {
  override init() {
    super.init()
    name = "HUD"
  }
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func add(message: String, position: CGPoint, fontSize: CGFloat = HUDSettings.fontSize) {
    let label = SKLabelNode(fontNamed: HUDSettings.font)
    label.text = message
    label.name = message
    label.fontSize = HUDSettings.fontSize
    label.zPosition = 100
    addChild(label)
    label.position = position
  }
}
