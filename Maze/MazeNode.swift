//
//  MazeNode.swift
//  Maze
//
//  Created by Michael Kalinin on 11/01/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

import Foundation
import SpriteKit

class MazeNode: SKShapeNode {

    let maxMovesDepth: Int = 3
    
    var mazeModel: MazeModel
    
    var width: CGFloat
    var height: CGFloat
    
    var playerCoord: Cell

    var movesTree: Node<Move>?
    
    init(row: Int, col: Int) {
        
        mazeModel = MazeModel(row: row, col: col)
        mazeModel.generate()
        
        playerCoord = Cell(row / 2, col / 2)
        
        width = CGFloat(mazeModel.colNumber) * UI.wallLength
        height = CGFloat(mazeModel.rowNumber) * UI.wallLength
        
        super.init()
        
        strokeColor = SKColor.clear
        fillColor = SKColor.clear
    }
    
    init(mazeModel: MazeModel) {
        
        self.mazeModel = mazeModel
        
        playerCoord = Cell(mazeModel.rowNumber / 2, mazeModel.colNumber / 2)
        
        width = CGFloat(mazeModel.colNumber) * UI.wallLength
        height = CGFloat(mazeModel.rowNumber) * UI.wallLength
        
        super.init()
        
        strokeColor = SKColor.clear
        fillColor = SKColor.clear       
    }
    
    // MARK: Player
    
    func isPlayerOut() -> Bool {
        if playerCoord.row == -1 || (playerCoord.row == mazeModel.rowNumber && mazeModel.rowNumber != 0) {
            return true
        } else {
            return false
        }
    }
    
    func checkPlayer(direction: Direction) -> Bool {
        return !mazeModel.checkWall(cell: playerCoord, direction: direction)
    }

    func makeMove(direction: Direction) {
        
        playerCoord.makeMove(to: direction)
        
        if !isPlayerOut() {
            drawMoves()
        }
    }
    
    // MARK: Walls
    
    func drawMaze() {
        for row in 0..<mazeModel.maze.count {
            let colCount = mazeModel.maze[row].count
            for col in 0..<colCount {
                if mazeModel.maze[row][col] {
                    drawWall(row, col)
                }
            }
        }
        
        if !isPlayerOut() {
            drawMoves()
        }        
    }
    
    func drawWall(_ row: Int, _ col: Int) {

        let horizontal = (row % 2) == 0
        
        let path = CGMutablePath()
        
        if horizontal {
            let start = CGPoint(x: CGFloat(col) * UI.wallLength - (width / 2.0),
                                y: (height / 2.0) - UI.wallLength * CGFloat(row) / 2)
            var end = start
            end.x += UI.wallLength
            
            path.move(to: start)
            path.addLine(to: end)
        } else {
            let start = CGPoint(x: CGFloat(col) * UI.wallLength - (width / 2.0),
                                y: (height / 2.0) - UI.wallLength * CGFloat(row - 1) / 2)
            var end = start
            end.y -= UI.wallLength
            
            path.move(to: start)
            path.addLine(to: end)
        }
        
        let wall = SKShapeNode(path: path)
        wall.strokeColor = SKColor.darkGray
        
        self.addChild(wall)
    }
    
    // MARK: Moves
    
    func drawMoves() {
        
        if movesTree != nil {
            removeMoves(node: movesTree!)
            movesTree = nil
        }
        
        getMoves()
        
        if movesTree != nil {
            drawMoves(node: movesTree!)
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
        movesTree = Node<Move>(value: rootMove)
        
        getMoves(node: movesTree!, depth: 0)
    }
    
    func getMoves(node: Node<Move>, depth: Int) {
        
        let cell = node.value.cell
        
        if depth == maxMovesDepth {
            return
        } else {
            if mazeModel.checkCell(cell: cell) {
                for direction in Direction.all {
                    if !mazeModel.checkWall(cell: cell, direction: direction) {
                        
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

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
