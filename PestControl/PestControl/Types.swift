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
