//
//  Direction.swift
//  Maze
//
//  Created by Michael Kalinin on 06/12/2016.
//  Copyright © 2016 Michael. All rights reserved.
//

import Foundation

enum Direction: Int {
    
    case up = 0
    case down
    case left
    case right
    
    static var all: [Direction] {
        return [.up, .down, .left, .right]
    }
    
    static func all(exclude: Direction) -> [Direction] {
        var directions = Direction.all
        if let index = directions.index(of: exclude) {
            directions.remove(at: index)
        }
        return directions
    }
    
    static func random() -> Direction {
        let max = right.rawValue
        let rand = arc4random_uniform(UInt32(max + 1))
        return Direction(rawValue: Int(rand))!
    }
    
    static func random(exclude: Direction) -> Direction {
        var direction: Direction
        repeat {
            direction = random()
        } while (direction == exclude)        
        return direction
    }
    
    static func random(exclude: [Direction]) -> Direction {
        var direction: Direction
        repeat {
            direction = random()
        } while (exclude.contains(direction))
        return direction
    }
    
    func inverse() -> Direction {
        switch self {
        case .up:    return .down
        case .down:  return .up
        case .left:  return .right
        case .right: return .left
        }
    }
    
    func isHorizontal() -> Bool {
        switch self {
        case .up:    return false
        case .down:  return false
        case .left:  return true
        case .right: return true
        }
    }
}
