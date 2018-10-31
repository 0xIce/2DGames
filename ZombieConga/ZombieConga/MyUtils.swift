//
//  MyUtils.swift
//  ZombieConga
//
//  Created by 马红奇 on 2018/10/29.
//  Copyright © 2018 hotch. All rights reserved.
//

import AVFoundation
import CoreGraphics
import Foundation

let π = CGFloat.pi

func + (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func += (left: inout CGPoint, right: CGPoint) {
  left = left + right
}

func + (left: CGPoint, right: CGFloat) -> CGPoint {
  return CGPoint(x: left.x + right, y: left.y + right)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func -= (left: inout CGPoint, right: CGPoint) {
  left = left - right
}

func * (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

func *= (left: inout CGPoint, right: CGPoint) {
  left = left * right
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func *= (point: inout CGPoint, scalar: CGFloat) {
  point = point * scalar
}

func / (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

func /= (left: inout CGPoint, right: CGPoint) {
  left = left / right
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func /= (point: inout CGPoint, scalar: CGFloat) {
  point = point / scalar
}

func shortestAngleBetween(angle1: CGFloat, angle2: CGFloat) -> CGFloat {
  let twoπ = π * 2.0
  var angle = (angle2 - angle1).truncatingRemainder(dividingBy: twoπ)
  if angle > π {
    angle -= twoπ
  } else if angle < -π {
    angle += twoπ
  }
  return angle
}

extension CGPoint {
  var length: CGFloat {
    return sqrt(x * x + y * y)
  }
  
  var normalized: CGPoint {
    return self / length
  }
  
  var angle: CGFloat {
    return atan2(y, x)
  }
}


extension CGFloat {
  var sign: CGFloat {
    return self > 0.0 ? 1.0 : -1.0
  }
  
  static func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / Float(UInt32.max))
  }
  
  static func random(min: CGFloat, max: CGFloat) -> CGFloat {
    assert(min < max)
    return random() * (max - min) + min
  }
}


// MARK: audio
var backgroundMusicPlayer: AVAudioPlayer!

func playBackgroundMusic(filename: String) {
  let resourceUrl = Bundle.main.url(forResource: filename, withExtension: nil)
  guard let url = resourceUrl else {
    print("Could not find file: \(filename)")
    return
  }
  do {
    try backgroundMusicPlayer = AVAudioPlayer(contentsOf: url)
    backgroundMusicPlayer.numberOfLoops = -1
    backgroundMusicPlayer.prepareToPlay()
    backgroundMusicPlayer.play()
  } catch {
    print("Could not create audio player!")
    return
  }
}

