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
    
    let cornerRadius: CGFloat = 2.0
    
    var cell: Cell
    var depth: Int
    
    let innerRectNode: SKShapeNode
    
    init(cell: Cell, depth: Int) {
        
        self.cell = cell
        self.depth = depth
        
        let innerRectSize = 5.0 * CGFloat(depth)
        
        self.innerRectNode = SKShapeNode(rectOf: CGSize(width: innerRectSize, height: innerRectSize), cornerRadius: cornerRadius)
        self.innerRectNode.fillColor = SKColor.white
        
        super.init()
        
        path = path(value: 0)
        
        strokeColor = SKColor.darkGray
        
        //fillColor = SKColor.darkGray
        //addChild(innerRectNode)
    }
    
    func updateDepth(value: CGFloat) {
        path = path(value: value)
        innerRectNode.path = innerPath(value: value)
    }
    
    func path(value: CGFloat) -> CGPath {
        
        let offset: CGFloat = 10.0 + (CGFloat(depth) + value) * 2
        let size = UI.wallLength - 2 * offset
        
        let rect = CGRect(origin: CGPoint(x: -size / 2.0, y: -size / 2.0),
                          size: CGSize(width: size, height: size))
        
        return CGPath(roundedRect: rect,
                      cornerWidth: cornerRadius,
                      cornerHeight: cornerRadius,
                      transform: nil)
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
