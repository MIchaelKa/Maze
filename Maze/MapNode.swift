//
//  MapNode.swift
//  Maze
//
//  Created by Michael Kalinin on 16/02/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

import Foundation
import SpriteKit

class MapNode: SKShapeNode {
    
    let maxMovesDepth: Int = 3
    
    var rowNumber: Int
    var colNumber: Int
    
    var width: CGFloat
    var height: CGFloat
    
    var playerCoord: Cell
    var playerTree: Node<Move>?
    
    var savedPosition: CGPoint!
    
    var currentMaze: MazeNode?
    
    init(row: Int, col: Int) {
        
        rowNumber = row
        colNumber = col
        
        width = CGFloat(row) * UI.wallLength
        height = CGFloat(col) * UI.wallLength
        
        playerCoord = Cell(row / 2, col / 2)
        
        super.init()
        
        let rect = CGRect(origin: CGPoint(x: -(width / 2.0), y: -(height / 2.0)),
                          size: CGSize(width: width, height: height))
        
        path = CGPath(rect: rect, transform: nil)
        
        strokeColor = SKColor.lightGray
        fillColor = SKColor.clear
    }
    
    func addMazeNode(node: MazeNode) {
        
        node.position = CGPoint(x: CGFloat(node.mapPosition.col) * UI.wallLength - (width / 2.0) + UI.wallLength / 2,
                                y: (height / 2.0) - CGFloat(node.mapPosition.row) * UI.wallLength - UI.wallLength / 2)
        
        addChild(node)
    }
    
    // MARK: Move
    
    func makeMove(direction: Direction) {
        
        playerCoord.makeMove(to: direction)
        
        print("[MapNode] makeMove: \(direction) - (\(playerCoord.row), \(playerCoord.col))")
        
        switch direction {
        case .up:    savedPosition.y -= UI.wallLength
        case .down:  savedPosition.y += UI.wallLength
        case .left:  savedPosition.x += UI.wallLength
        case .right: savedPosition.x -= UI.wallLength
        }
        
        currentMaze = checkMazeCell(cell: playerCoord)
        
        drawPlayer()
    }
    
    func move(_ pos: CGPoint, direction: Direction) {
        
        var offset: CGFloat
        if direction.isHorizontal() {
            offset = abs(position.x - pos.x) / UI.wallLength
        } else {
            offset = abs(position.y - pos.y) / UI.wallLength
        }
        
        position = pos
        
        let currentTranslation = savedPosition - position
        
        if currentTranslation.direction == direction {
            
            if let moveChilds = playerTree?.childs(from: direction) {
                for child in moveChilds {
                    child.value.updateDepth(value: -offset)
                }
            }
            
            if let otherChilds = playerTree?.childs(exclude: direction) {
                for child in otherChilds {
                    child.value.updateDepth(value: offset)
                }
            }
            
        } else {
            
            if let otherChilds = playerTree?.childs(from: direction.inverse()) {
                for child in otherChilds {
                    child.value.updateDepth(value: offset)
                }
            }
            
            if let moveChilds = playerTree?.childs(exclude: direction.inverse()) {
                for child in moveChilds {
                    child.value.updateDepth(value: -offset)
                }
            }
        }        
        
        // Root
        
        if direction.isHorizontal() {
            offset = abs(position.x - savedPosition.x) / UI.wallLength
        } else {
            offset = abs(position.y - savedPosition.y) / UI.wallLength
        }
        
        playerTree?.value.updateRootDepth(value: offset)
    }
    
    // MARK: Player & Moves    
    
    func drawPlayer() {
        if playerTree != nil {
            removeMoves(node: playerTree!)
            playerTree = nil
        }
        
        getMoves()
        
        if playerTree != nil {
            drawMoves(node: playerTree!)
        }
    }
    
    func removeMoves(node: Node<Move>) {
        node.value.removeFromParent()
        
        for direction in Direction.all {
            if let child = node.child(from: direction) {
                removeMoves(node: child)
            }
        }
    }
    
    func drawMoves(node: Node<Move>) {
        drawMove(move: node.value)
        
        for direction in Direction.all {
            if let child = node.child(from: direction) {
                drawMoves(node: child)
            }
        }
    }
    
    func drawMove(move: Move) {
        
        move.position = CGPoint(x: CGFloat(move.cell.col) * UI.wallLength - (width / 2.0) + UI.wallLength / 2,
                                y: (height / 2.0) - CGFloat(move.cell.row) * UI.wallLength - UI.wallLength / 2)
        self.addChild(move)
    }
    
    func getMoves() {
        
        let rootMove = Move(cell: playerCoord, depth: 0)
        playerTree = Node<Move>(value: rootMove)
        
        getMoves(node: playerTree!, depth: 1)
    }
    
    func getMoves(node: Node<Move>, depth: Int) {
        
        let cell = node.value.cell
        
        if depth == maxMovesDepth {
            return
        } else {
            if checkBound(cell: cell) {
                for direction in Direction.all {
                    if checkCell(cell: cell, direction: direction) {
                        
                        let newCell = cell.getCell(from: direction)
                        
                        if let parentCell = node.parent?.value.cell {
                            if parentCell == newCell {
                                continue
                            }
                        }
                        
                        let moveToAdd = Move(cell: newCell, depth: depth)
                        let childNode = Node<Move>(value: moveToAdd)
                        
                        node.add(child: childNode, to: direction)
                        getMoves(node: childNode, depth: depth + 1)
                    }
                }
            }
        }
    }
    
    // MARK: Check player
    
    func checkMazeCell(cell: Cell) -> MazeNode? {
        
        for node in children {
            if let maze = node as? MazeNode {
                if checkMazeCell(maze: maze, cell: cell) {
                    return maze
                }
            }
        }
        
        return nil
    }
    
    func checkMazeCell(maze: MazeNode, cell: Cell) -> Bool {
        
        let topLeft = maze.topLeft
        let bottomRight = maze.bottomRight
        
        if (cell.row >= topLeft.row && cell.row <= bottomRight.row) &&
           (cell.col >= topLeft.col && cell.col <= bottomRight.col)
        {
            return true
        }
        return false
    }
    
    func checkChildNodes(cell: Cell, direction: Direction) -> Bool {
        for node in children {
            if let maze = node as? MazeNode {
                if !checkMazeBound(maze: maze, cell: cell, direction: direction) {
                    return false
                }
            }
        }
        return true
    }
    
    func checkMazeBound(maze: MazeNode, cell: Cell, direction: Direction) -> Bool {
        
        let topLeft = maze.topLeft
        let bottomRight = maze.bottomRight
        
        var mazeDirection: Direction?
        
        if cell.row >= topLeft.row && cell.row <= bottomRight.row {
            if cell.col == topLeft.col - 1 {
                mazeDirection = .right
            } else if cell.col == bottomRight.col + 1 {
                mazeDirection = .left
            }
        } else if cell.col >= topLeft.col && cell.col <= bottomRight.col {
            if cell.row == topLeft.row - 1 {
                mazeDirection = .down
            } else if cell.row == bottomRight.row + 1 {
                mazeDirection = .up
            }
        }
        
        if mazeDirection != nil {
            if mazeDirection! == direction {
                
                var next = cell.getCell(from: direction)
                next = maze.mapCellToMazeCell(cell: next)
                
                if maze.checkCell(cell: next, direction: direction.inverse()) {
                    return true
                }
                return false
            }
        }
        
        return true
    }
    
    func checkPlayer(direction: Direction) -> Bool {
        return checkCell(cell: playerCoord, direction: direction)
    }
    
    func checkCell(cell: Cell, direction: Direction) -> Bool {      
        
        if currentMaze != nil {
            let mazeCell = currentMaze!.mapCellToMazeCell(cell: cell)
            return currentMaze!.checkCell(cell: mazeCell, direction: direction)
        }
        
        if checkBound(cell: cell, direction: direction) {
            if checkChildNodes(cell: cell, direction: direction) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func checkBound(cell: Cell, direction: Direction) -> Bool {
        let next = cell.getCell(from: direction)
        return checkBound(cell: next)
    }
    
    func checkBound(cell: Cell) -> Bool {
        if (cell.row >= 0 && cell.row < rowNumber) && (cell.col >= 0 && cell.col < colNumber) {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Moves
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
