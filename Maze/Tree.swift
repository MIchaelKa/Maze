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
    
    func getLeaf() -> Node<Type> {
        
        for direction in Direction.all {
            if let child = self.child(from: direction) {
                return child.getLeaf()
            }
        }
        
        return self
    }
    
    func leafs() -> [Node<Type>] {
        
        var leafs = [Node<Type>]()
        
        for direction in Direction.all {
            if let child = self.child(from: direction) {
                let childLeafs = child.leafs()
                leafs.append(contentsOf: childLeafs)
            }
        }
        
        if leafs.count == 0 {
            return [self]
        }
        
        return leafs        
    }
    
    func all() -> [Node<Type>] {
        
        var all = [Node<Type>]()
        
        for direction in Direction.all {
            if let child = self.child(from: direction) {
                all.append(contentsOf: child.all())
            }
        }
        
        if all.count == 0 {
            return [self]
        } else {
            all.append(self)
        }
        
        return all
    }
    
    func childs(from direction: Direction) -> [Node<Type>] {
        if let child = self.child(from: direction) {
            return child.all()
        } else {
            return []
        }
    }
    
    func childs(exclude direction: Direction) -> [Node<Type>] {
        
        var childs = [Node<Type>]()
        let directions = Direction.all(exclude: direction)
        
        for direction in directions {
            if let child = self.child(from: direction) {
                childs.append(contentsOf: child.all())
            }
        }
        
        return childs
    }
    
    
}
