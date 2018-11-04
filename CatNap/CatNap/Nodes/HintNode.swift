//
//  HintNode.swift
//  CatNap
//
//  Created by 马红奇 on 2018/11/5.
//  Copyright © 2018 hotch. All rights reserved.
//

import SpriteKit

class HintNode: SKSpriteNode {
  private let randomColor: [SKColor] = [.red, .gray, .yellow, .green, .blue, .orange]
  
  private var arrowPath: CGPath = {
    let bezierPath = UIBezierPath()
    bezierPath.move(to: CGPoint(x: 0.5, y: 65.69))
    bezierPath.addLine(to: CGPoint(x: 74.99, y: 1.5))
    bezierPath.addLine(to: CGPoint(x: 74.99, y: 38.66))
    bezierPath.addLine(to: CGPoint(x: 257.5, y: 38.66))
    bezierPath.addLine(to: CGPoint(x: 257.5, y: 92.72))
    bezierPath.addLine(to: CGPoint(x: 74.99, y: 92.72))
    bezierPath.addLine(to: CGPoint(x: 74.99, y: 126.5))
    bezierPath.addLine(to: CGPoint(x: 0.5, y: 65.69))
    bezierPath.close()
    return bezierPath.cgPath
  }()
  
  private lazy var shape: SKShapeNode = {
    let shape = SKShapeNode(path: arrowPath)
    shape.strokeColor = .gray
    shape.lineWidth = 4
    shape.fillColor = .white
    shape.fillTexture = SKTexture(imageNamed: "wood_tinted")
    shape.alpha = 0.8
    return shape
  }()
  
  
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    interact()
  }
}

extension HintNode: EventListenerNode {
  func didMoveToScene() {
    color = .clear
    isUserInteractionEnabled = true
    
//    let shape = SKShapeNode(rectOf: size, cornerRadius: 20)
//    shape.strokeColor = .red
//    shape.lineWidth = 4
//    shape.glowWidth = 5
//    shape.fillColor = .white
//    addChild(shape)
    
    addChild(shape)
    
    let move = SKAction.moveBy(x: -40, y: 0, duration: 1.0)
    shape.run(SKAction.repeat(SKAction.sequence([move, move.reversed()]), count: 3)) {
      self.removeFromParent()
    }
  }
}

extension HintNode: InteractiveNode {
  func interact() {
    shape.fillColor = randomColor.randomElement()!
  }
}
