//
//  Move.swift
//  Maze
//
//  Created by Michael Kalinin on 27/01/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

import Foundation
import SpriteKit

class Move: SKShapeNode {
    
    let cornerRadius: CGFloat = 3.0
    
    var cell: Cell
    var depth: Int
    var floatDepth: CGFloat
    
    let innerRectNode: SKShapeNode
    
    init(cell: Cell, depth: Int) {
        
        self.cell = cell
        self.depth = depth
        self.floatDepth = CGFloat(depth)
        
        let innerRectSize = 5.0 * CGFloat(depth)
        
        self.innerRectNode = SKShapeNode(rectOf: CGSize(width: innerRectSize, height: innerRectSize), cornerRadius: cornerRadius)
        self.innerRectNode.fillColor = SKColor.white
        
        super.init()
        
        path = path(value: CGFloat(depth))
        
        strokeColor = SKColor.darkGray
        lineWidth = 1.5
        //fillColor = SKColor.darkGray
        //addChild(innerRectNode)
    }
    
    func updateDepth(value: CGFloat) {
        floatDepth += value
        path = path(value: floatDepth)
    }
    
    func updateRootDepth(value: CGFloat) {
        let newDepth = CGFloat(depth) + value
        path = path(value: newDepth)
    }
    
    func path(value: CGFloat) -> CGPath {
       
        let offset: CGFloat = 10.0 + value * 4
        let size = UI.wallLength - 2 * offset
        
        let rect = CGRect(origin: CGPoint(x: -size / 2.0, y: -size / 2.0),
                          size: CGSize(width: size, height: size))
       
        if 2 * cornerRadius > size {
            return CGPath(rect: rect, transform: nil)
        } else {
            return CGPath(roundedRect: rect,
                          cornerWidth: cornerRadius,
                          cornerHeight: cornerRadius,
                          transform: nil)
        }       
    }
    
    func innerPath(value: CGFloat) -> CGPath {
        let innerRectSize = 5.0 * (CGFloat(depth) + value)
        let innerRect = CGRect(origin: CGPoint(x: -innerRectSize / 2.0, y: -innerRectSize / 2.0),
                               size: CGSize(width: innerRectSize, height: innerRectSize))
        return CGPath(rect: innerRect, transform: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
