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
    
    var cell: Cell
    var depth: Int
    
    init(cell: Cell, depth: Int) {
        
        self.cell = cell
        self.depth = depth
        super.init()
        
        let offset: CGFloat = 10.0 + CGFloat(depth) * 2
        let size = UI.wallLength - 2 * offset
        
        
        let rect = CGRect(origin: CGPoint(x: -size / 2.0, y: -size / 2.0),
                          size: CGSize(width: size, height: size))
        
        path = CGPath(rect: rect, transform: nil)
        strokeColor = SKColor.darkGray
    }
    
    func updateDepth(value: CGFloat) {
        
        let offset: CGFloat = 10.0 + (CGFloat(depth) + value) * 2
        let size = UI.wallLength - 2 * offset
        
        
        let rect = CGRect(origin: CGPoint(x: -size / 2.0, y: -size / 2.0),
                          size: CGSize(width: size, height: size))
        path = CGPath(rect: rect, transform: nil)
    }
    
    func path(value: CGFloat) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
