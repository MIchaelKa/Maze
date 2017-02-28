//
//  LifeCellNode.swift
//  Maze
//
//  Created by Michael Kalinin on 21/02/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

import Foundation
import SpriteKit

class LifeCellNode: SKShapeNode {
    
    let cornerRadius: CGFloat = 3.0
    let animationTime: CGFloat = 0.25
    let offset: CGFloat = 7.0
    
    var cell: Cell
    
    init(cell: Cell) {
        self.cell = cell
        super.init()
        
        fillColor = SKColor.darkGray        
        path = path(time: 0.0)
    }
    
    func show() {
        
        let showAction = SKAction.customAction(withDuration: TimeInterval(animationTime)) { [unowned self] node, time in
            if let shapeNode = node as? SKShapeNode {
                shapeNode.path = self.path(time: time)
                let alpha = 1 - (1 / self.animationTime) * time
                shapeNode.fillColor = SKColor.darkGray.withAlphaComponent(1 - alpha)
            }
        }
        
        run(showAction)        
    }
    
    func hide() {
        
        let hideAction = SKAction.customAction(withDuration: TimeInterval(animationTime)) { [unowned self] node, time in
            if let shapeNode = node as? SKShapeNode {
                shapeNode.path = self.path(time: self.animationTime - time)
                let alpha = 1 - (1 / self.animationTime) * time
                shapeNode.fillColor = SKColor.darkGray.withAlphaComponent(alpha)
            }
        }
        
        run(hideAction) { [weak self] in
            self?.removeFromParent()
        }
    }
    
    func path(time: CGFloat) -> CGPath {
        
        let ratio = (1 / animationTime) * time
        
        let size = (UI.wallLength - 2 * offset) * ratio
        
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
