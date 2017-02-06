//
//  CGPoint+Extension.swift
//  Maze
//
//  Created by Michael Kalinin on 06/02/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGPoint {
    
    var direction: Direction {
        if abs(self.x) > abs(self.y) {
            if self.x > 0 {
                return .right
            } else {
                return .left
            }
        } else {
            if self.y > 0 {
                return .up
            } else {
                return .down
            }
        }
    }
    
    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
    
}
