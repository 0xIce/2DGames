//
//  DiscoBallNode.swift
//  CatNap
//
//  Created by 马红奇 on 2018/11/5.
//  Copyright © 2018 hotch. All rights reserved.
//

import AVFoundation
import SpriteKit

class DiscoBallNode: SKSpriteNode {
  private var player: AVPlayer!
  private var video: SKVideoNode!
  private var isDiscoTime: Bool = false {
    didSet {
      video.isHidden = !isDiscoTime
      if isDiscoTime {
        video.play()
        run(spinAction)
        SKTAudio.sharedInstance().playBackgroundMusic("disco-sound.m4a")
        video.run(SKAction.wait(forDuration: 5.0)) {
          self.isDiscoTime = false
        }
      } else {
        video.pause()
        removeAllActions()
        SKTAudio.sharedInstance().playBackgroundMusic("backgroundMusic.mp3")
      }
    }
  }
  private let spinAction = SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed: "discoball1"),
                                                                          SKTexture(imageNamed: "discoball2"),
                                                                          SKTexture(imageNamed: "discoball3")], timePerFrame: 0.2))
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    interact()
  }
}

extension DiscoBallNode: EventListenerNode {
  func didMoveToScene() {
    isUserInteractionEnabled = true
    
    let fileUrl = Bundle.main.url(forResource: "discolights-loop", withExtension: "mov")!
    player = AVPlayer(url: fileUrl)
    video = SKVideoNode(avPlayer: player)
    
    video.alpha = 0.75
    video.size = scene!.size
    video.position = CGPoint(x: scene!.frame.midX, y: scene!.frame.midY)
    video.zPosition = -1
    scene!.addChild(video)
//    video.play()
    video.isHidden = true
    video.pause()
    
    NotificationCenter.default.addObserver(self, selector: #selector(didReachEndOfVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
  }
  
  @objc func didReachEndOfVideo() {
    print("rewind...")
    player.currentItem?.seek(to: CMTime.zero, completionHandler: { [weak self] (_) in
      self?.player.play()
    })
  }
}

extension DiscoBallNode: InteractiveNode {
  func interact() {
    isDiscoTime = true
  }
}
