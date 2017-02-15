//
//  MazeModel.swift
//  Maze
//
//  Created by Michael Kalinin on 11/01/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

import Foundation

class MazeModel {
    
    var rowNumber: Int
    var colNumber: Int
    
    var mainPath = Path()
    
    var maze: [[Bool]] = []
    
    init(row: Int, col: Int) {
        
        rowNumber = row
        colNumber = col
    }
    
    func generate() {
        clear()
        createAllWalls()
        createMainPath()
        joinAllCells()
    }
    
    func clear() {
        maze.removeAll()
        mainPath.clear()
    }
    
    func createAllWalls() {
        
        let rowCount = rowNumber * 2 + 1
        
        for index in 1...rowCount {
            let colCount = (index % 2) == 0 ? colNumber + 1 : colNumber
            let rowMaze = Array(repeating: true, count: colCount)
            maze.append(rowMaze)
        }
    }
    
    func createMainPath() {
        
        var rowIdx = 0
        var colIdx = Int(arc4random_uniform(UInt32(colNumber)))
        var direction = Direction.down
        
        let _ = mainPath.addCell(row: rowIdx, col: colIdx)
        
        let wall = getWall(row: rowIdx, col: colIdx, direction: .up)
        maze[wall.row][wall.col] = false
        
        while (rowIdx != rowNumber) {
            
            var exclude = [direction.inverse()]
            if rowIdx == 0 { exclude.append(.up) }
            if colIdx == 0 { exclude.append(.left) }
            if colIdx == colNumber - 1 { exclude.append(.right) }
            
            direction = Direction.random(exclude: exclude)
            
            let wall = getWall(row: rowIdx, col: colIdx, direction: direction)            
            
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
            
            if mainPath.addCell(row: rowIdx, col: colIdx) {
                maze[wall.row][wall.col] = false
            }
        }
    }
    
    func joinAllCells() {
        for rowIdx in 0..<rowNumber {
            for colIdx in 0..<colNumber {
                if isClosedCell(row: rowIdx, col: colIdx) {
                    joinCellToMainPath(row: rowIdx, col: colIdx)
                    
                }
            }
        }
    }
    
    func joinCellToMainPath(row: Int, col: Int) {
        
        var rowIdx = row
        var colIdx = col
        
        var direction = Direction.up
        
        let path = Path()
        
        let _ = path.addCell(row: rowIdx, col: colIdx)
        
        var isMainPath = false
        
        while !isMainPath {
            
            var exclude = [direction.inverse()] // no need for first iteration. use optional?
            if rowIdx == 0             { exclude.append(.up) }
            if rowIdx == rowNumber - 1 { exclude.append(.down) }
            if colIdx == 0             { exclude.append(.left) }
            if colIdx == colNumber - 1 { exclude.append(.right) }
            
            direction = Direction.random(exclude: exclude)
            
            let wall = getWall(row: rowIdx, col: colIdx, direction: direction)

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
            
            if mainPath.contains(row: rowIdx, col: colIdx) {
                isMainPath = true
                maze[wall.row][wall.col] = false
            } else if path.addCell(row: rowIdx, col: colIdx) {
                maze[wall.row][wall.col] = false
            }
        }
        
        mainPath.add(path: path)        
    }
    
    func isClosedCell(row: Int, col: Int) -> Bool {
        for direction in Direction.all {
            let wall = getWall(row: row, col: col, direction: direction)
            if !maze[wall.row][wall.col] {
                return false
            }
        }
        return true
    }
    
    func checkCell(cell: Cell) -> Bool {
        if (cell.row >= 0 && cell.row < rowNumber) && (cell.col >= 0 && cell.col < colNumber) {
            return true
        } else {
            return false
        }
    }
    
    func getMoves(cell: Cell) -> [Cell] {
        var moves = [Cell]()
        
        for direction in Direction.all {
            if !checkWall(cell: cell, direction: direction) {
                moves.append(cell.getCell(from: direction))
            }
        }
        
        return moves
    }
    
    // MARK: Walls
    
    func checkWall(cell: Cell, direction: Direction) -> Bool {
        let wall = getWall(row: cell.row, col: cell.col, direction: direction)
        return maze[wall.row][wall.col]
    }
    
    func removeWall(cell: Cell, direction: Direction) {
        let wall = getWall(row: cell.row, col: cell.col, direction: direction)
        maze[wall.row][wall.col] = false
    }
    
    func getWall(row: Int, col: Int, direction: Direction) -> (row: Int, col: Int) {
        switch direction {
            case .up:    return (row: row * 2,       col: col)
            case .down:  return (row: (row * 2) + 2, col: col)
            case .left:  return (row: (row * 2) + 1, col: col)
            case .right: return (row: (row * 2) + 1, col: col + 1)
        }
    }
    
}
