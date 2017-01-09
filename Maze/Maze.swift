//
//  Maze.swift
//  Maze
//
//  Created by Michael Kalinin on 09/12/2016.
//  Copyright © 2016 Michael. All rights reserved.
//

import SpriteKit

class Maze {
    
    var rowNumber: Int
    var colNumber: Int
    
    var path: [Cell] = []
    var maze: [[Bool]] = []
    
    var scene: SKScene?
    
    init(row: Int, col: Int) {
        rowNumber = row
        colNumber = col
        
        generate()
    }
    
    func generate() {
        clear()
        createAllWalls()
        createMainPath()
    }
    
    func clear() {
        scene?.removeAllChildren()
        maze.removeAll()
        path.removeAll()
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

    }
    
}
