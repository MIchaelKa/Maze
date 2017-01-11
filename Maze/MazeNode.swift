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
    
    var mazeModel: MazeModel
    
    var width: CGFloat
    var height: CGFloat
    
    var playerCoord: Cell = (0, 0)
    
    init(row: Int, col: Int) {
        
        mazeModel = MazeModel(row: row, col: col)
        mazeModel.generate()
        
        playerCoord = (row / 2, col / 2)
        
        width = CGFloat(mazeModel.colNumber) * wallLength
        height = CGFloat(mazeModel.rowNumber) * wallLength
        
        super.init()
        
        strokeColor = SKColor.clear
        fillColor = SKColor.clear
    }
    
    init(mazeModel: MazeModel) {
        
        self.mazeModel = mazeModel
        
        playerCoord = (mazeModel.rowNumber / 2, mazeModel.colNumber / 2)
        
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
        return !mazeModel.checkWall(row: playerCoord.row, col: playerCoord.col, direction: direction)
    }
    
    // class for cell with this function
    func makeMove(direction: Direction) {
        switch direction {
        case .up:
            playerCoord.row -= 1
        case .down:
            playerCoord.row += 1
        case .left:
            playerCoord.col -= 1
        case .right:
            playerCoord.col += 1
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
        
        drawMoves()
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
        for direction in Direction.all {
            if !mazeModel.checkWall(row: playerCoord.row, col: playerCoord.col, direction: direction) {
                drawMove(row: playerCoord.row, col: playerCoord.col, direction: direction)
            }
        }
    }
    
    func drawMove(row: Int, col: Int, direction: Direction) {
        
        var rowIdx = row
        var colIdx = col
        
        switch direction {
        case .up:
            rowIdx -= 1
        case .down:
            rowIdx += 1
        case .left:
            colIdx -= 1
        case .right:
            colIdx += 1
        }
        
        let offset: CGFloat = 10.0
        
        let move = SKShapeNode(rectOf: CGSize(width: wallLength - 2 * offset,
                                              height: wallLength - 2 * offset))
        
        move.position = CGPoint(x: CGFloat(colIdx) * wallLength + (2 * offset) - (width / 2.0),
                                y: (height / 2.0) - (2 * offset) - CGFloat(rowIdx) * wallLength)
        
        move.strokeColor = SKColor.darkGray
        
        self.addChild(move)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
