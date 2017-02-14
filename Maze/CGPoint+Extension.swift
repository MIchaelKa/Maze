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
    
    var secondDirection: Direction {
        if abs(self.x) < abs(self.y) {
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
    
    func componentLength(using direction: Direction) -> CGFloat {
        if direction.isHorizontal() {
            return abs(self.x)
        } else {
            return abs(self.y)
        }
    }
    
    func component(using direction: Direction) -> CGPoint {
        var result = self
        if direction.isHorizontal() {
            result.y = 0.0
        } else {
            result.x = 0.0
        }
        return result
    }
    
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
    static func += (left: inout CGPoint, right: CGPoint) {
        left = left + right
    }
    
    static func -= (left: inout CGPoint, right: CGPoint) {
        left = left - right
    }
    
    
}
