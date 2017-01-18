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
    
    let wallLength: CGFloat = 40.0
    let maxMovesDepth: Int = 3
    
    var mazeModel: MazeModel
    
    var width: CGFloat
    var height: CGFloat
    
    var playerCoord: Cell
    
    var moves: [SKNode] = []
    
    init(row: Int, col: Int) {
        
        mazeModel = MazeModel(row: row, col: col)
        mazeModel.generate()
        
        playerCoord = Cell(row / 2, col / 2)
        
        width = CGFloat(mazeModel.colNumber) * wallLength
        height = CGFloat(mazeModel.rowNumber) * wallLength
        
        super.init()
        
        strokeColor = SKColor.clear
        fillColor = SKColor.clear
    }
    
    init(mazeModel: MazeModel) {
        
        self.mazeModel = mazeModel
        
        playerCoord = Cell(mazeModel.rowNumber / 2, mazeModel.colNumber / 2)
        
        width = CGFloat(mazeModel.colNumber) * wallLength
        height = CGFloat(mazeModel.rowNumber) * wallLength
        
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
            let start = CGPoint(x: CGFloat(col) * wallLength - (width / 2.0),
                                y: (height / 2.0) - wallLength * CGFloat(row) / 2)
            var end = start
            end.x += wallLength
            
            path.move(to: start)
            path.addLine(to: end)
        } else {
            let start = CGPoint(x: CGFloat(col) * wallLength - (width / 2.0),
                                y: (height / 2.0) - wallLength * CGFloat(row - 1) / 2)
            var end = start
            end.y -= wallLength
            
            path.move(to: start)
            path.addLine(to: end)
        }
        
        let wall = SKShapeNode(path: path)
        wall.strokeColor = SKColor.darkGray
        
        self.addChild(wall)
    }
    
    // MARK: Moves
    
    func drawMoves() {
        
        for node in moves {
            node.removeFromParent()
        }
        
        moves.removeAll()
        
        drawMoves(cell: playerCoord, depth: 0)
    }
    
    func drawMoves(cell: Cell, depth: Int) {
        
        if depth == maxMovesDepth {
            return
        } else {
            if mazeModel.checkCell(cell: cell) {
                let moves = mazeModel.getMoves(cell: cell)
                for move in moves {
                    drawMove(cell: move, depth: depth)
                    drawMoves(cell: move, depth: depth + 1)
                }
            }            
        }        
    }
    
    func drawMove(cell: Cell, depth: Int) {
        
        let offset: CGFloat = 10.0 + CGFloat(depth) * 2
        
        let move = SKShapeNode(rectOf: CGSize(width: wallLength - 2 * offset,
                                              height: wallLength - 2 * offset))
        
        move.position = CGPoint(x: CGFloat(cell.col) * wallLength - (width / 2.0) + wallLength / 2,
                                y: (height / 2.0) - CGFloat(cell.row) * wallLength - wallLength / 2)

        
        move.strokeColor = SKColor.darkGray
        
        moves.append(move)
        self.addChild(move)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
