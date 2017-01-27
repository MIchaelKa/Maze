//
//  Tree.swift
//  Maze
//
//  Created by Michael Kalinin on 27/01/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

import Foundation

class Node<Type> {
    
    var value: Type
    
    var up: Node?
    var down: Node?
    var left: Node?
    var right: Node?
    
    weak var parent: Node?
    
    init(value: Type) {
        self.value = value
    }
    
    func add(child: Node, to direction: Direction) {
        switch direction {
            case .up:    up = child
            case .down:  down = child
            case .left:  left = child
            case .right: right = child
        }
        child.parent = self
    }
    
    func child(from direction: Direction) -> Node<Type>? {
        switch direction {
            case .up:    return up
            case .down:  return down
            case .left:  return left
            case .right: return right
        }
    }
    
    
}
