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
    
    var rowNumber: Int
    var colNumber: Int
    
    var mapPosition: Cell
    
    var topLeft: Cell {
        return Cell(mapPosition.row - rowNumber / 2,
                    mapPosition.col - colNumber / 2)
    }
    
    var bottomRight: Cell {
        return Cell(mapPosition.row + rowNumber / 2,
                    mapPosition.col + colNumber / 2)
    }
    
    var width: CGFloat
    var height: CGFloat
    
    convenience init(row: Int, col: Int, pos: Cell) {
        
        let mazeModel = MazeModel(row: row, col: col)
        mazeModel.generate()
        
        self.init(mazeModel: mazeModel, pos: pos)
    }
    
    init(mazeModel: MazeModel, pos: Cell) {
        
        self.mazeModel = mazeModel
        
        mapPosition = pos
        
        rowNumber = mazeModel.rowNumber
        colNumber = mazeModel.colNumber
        
        width = CGFloat(mazeModel.colNumber) * UI.wallLength
        height = CGFloat(mazeModel.rowNumber) * UI.wallLength
        
        super.init()
        
        let rect = CGRect(origin: CGPoint(x: -(width / 2.0), y: -(height / 2.0)),
                          size: CGSize(width: width, height: height))
        
        path = CGPath(rect: rect, transform: nil)
        
        strokeColor = SKColor.clear
        fillColor = SKColor.clear
        
        drawMaze()
    }
    
    // MARK: Player
    
    func checkCell(cell: Cell, direction: Direction) -> Bool {
        return !mazeModel.checkWall(cell: cell, direction: direction)
    }
    
    func mapCellToMazeCell(cell: Cell) -> Cell {
        return Cell(cell.row - topLeft.row, cell.col - topLeft.col)
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


    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
