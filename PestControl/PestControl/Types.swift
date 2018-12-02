//
//  Types.swift
//  PestControl
//
//  Created by 马红奇 on 2018/11/5.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import Foundation

typealias TileCoordinates = (column: Int, row: Int)

enum Direction: Int {
  case forward = 0, backward, left, right
}

struct PhysicsCategory {
  static let None:      UInt32 = 0
  static let All:       UInt32 = 0xFFFFFFFF
  static let Edge:      UInt32 = 0b1
  static let Player:    UInt32 = 0b10
  static let Bug:       UInt32 = 0b100
  static let Firebug:   UInt32 = 0b1000
  static let Breakable: UInt32 = 0b10000
}
