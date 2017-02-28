//
//  ButtonNode.swift
//  Maze
//
//  Created by Michael Kalinin on 27/02/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

import Foundation
import SpriteKit

class ButtonNode: SKShapeNode {
    
    let cornerRadius: CGFloat = 3.0
    let offset: CGFloat = 7.0
    
    init(cell: Cell) {
        super.init()
        
        fillColor = SKColor.darkGray
    }
    
    func path(time: CGFloat) -> CGPath {
        
        let size = (UI.wallLength - 2 * offset)
        
        let rect = CGRect(origin: CGPoint(x: -size / 2.0, y: -size / 2.0),
                          size: CGSize(width: size, height: size))
        
        if 2 * cornerRadius > size {
            return CGPath(ellipseIn: rect, transform: nil)
        } else {
            return CGPath(roundedRect: rect,
                          cornerWidth: cornerRadius,
                          cornerHeight: cornerRadius,
                          transform: nil)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
