//
//  PictureNode.swift
//  CatNap
//
//  Created by 马红奇 on 2018/11/4.
//  Copyright © 2018 hotch. All rights reserved.
//

import SpriteKit

class PictureNode: SKSpriteNode {
  
}

extension PictureNode: EventListenerNode {
  func didMoveToScene() {
    isUserInteractionEnabled = true
    
    let pictureNode = SKSpriteNode(imageNamed: "picture")
    let maskNode = SKSpriteNode(imageNamed: "picture-frame-mask")
    
    let cropNode = SKCropNode()
    cropNode.addChild(pictureNode)
    cropNode.maskNode = maskNode
    addChild(cropNode)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    interact()
  }
}


extension PictureNode: InteractiveNode {
  func interact() {
    isUserInteractionEnabled = false
    physicsBody?.isDynamic = true
  }
}
