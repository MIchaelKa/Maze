//
//  GameScene.swift
//  Maze
//
//  Created by Michael Kalinin on 05/12/2016.
//  Copyright © 2016 Michael. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

typealias Cell = (row: Int, col: Int)

class GameScene: SKScene {
    
    let wallLength: CGFloat = 40.0
    
    var rowNumber: Int = 0
    var colNumber: Int = 0
    
    var maze: [[Bool]] = []
    
    var path: [Cell] = []
    
    var world: SKShapeNode?
    
    var motionManager = CMMotionManager()
    
    var worldDestanationX: CGFloat = 0.0
    var worldDestanationY: CGFloat = 0.0
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        
        showMaze()
        //setupAccelerometerControl()
    }
    
    func showMaze() {
        initMaze(row: 15, col: 15)
        drawMaze()
    }
    
    func initMaze(row: Int, col: Int) {
        
        rowNumber = row
        colNumber = col
        
        // 0. Clear all
        
        self.removeAllChildren()
        world?.removeAllChildren()
        maze.removeAll()
        path.removeAll()
        
        // 1. Create all walls
        
        let rowCount = row * 2 + 1
        
        for index in 1...rowCount {
            let colCount = (index % 2) == 0 ? col + 1 : col
            let rowMaze = Array(repeating: true, count: colCount)
            maze.append(rowMaze)
        }
        
        // 2. Create the main path
        
        var rowIdx = 0
        var colIdx = Int(arc4random_uniform(UInt32(col)))
        var direction = Direction.down
        
        let _ = addCellToPath(row: rowIdx, col: colIdx)
        
        let wall = getWall(row: rowIdx, col: colIdx, direction: .up)
        maze[wall.row][wall.col] = false
        
        while (rowIdx != row) {

            var exclude = [direction.inverse()]
            if rowIdx == 0 { exclude.append(.up) }
            if colIdx == 0 { exclude.append(.left) }
            if colIdx == col - 1 { exclude.append(.right) }
            
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
            
            if addCellToPath(row: rowIdx, col: colIdx) {
                maze[wall.row][wall.col] = false
            }
        }
        
        // 3. Join each cell with the main path
        join()
        
        print(path.count)
        
    }
    
    func join() {
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
        
        while !isMainPath(row: rowIdx, col: colIdx) {
            
            var exclude = [direction.inverse()] // no need for first iteration. use optional?
            if rowIdx == 0             { exclude.append(.up) }
            if rowIdx == rowNumber - 1 { exclude.append(.down) }
            if colIdx == 0             { exclude.append(.left) }
            if colIdx == colNumber - 1 { exclude.append(.right) }
            
            direction = Direction.random(exclude: exclude)
            
            let wall = getWall(row: rowIdx, col: colIdx, direction: direction)
            
            // add all cells to main at the end, use separate path
            if !addCellToPath(row: rowIdx, col: colIdx) {
                print("Error")
            }
            
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
            
            maze[wall.row][wall.col] = false
        }
    }
    
    func isMainPath(row: Int, col: Int) -> Bool {
        for cell in path {
            if cell.row == row && cell.col == col {
                return true
            }
        }
        return false
    }
    
    func addCellToPath(row: Int, col: Int) -> Bool {
        for cell in path {
            if cell.row == row && cell.col == col {
                return false
            }
        }
        path.append((row, col))
        return true
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
    
    func getWall(row: Int, col: Int, direction: Direction) -> (row: Int, col: Int) {
        switch direction {
            case .up:    return (row: row * 2,       col: col)
            case .down:  return (row: (row * 2) + 2, col: col)
            case .left:  return (row: (row * 2) + 1, col: col)
            case .right: return (row: (row * 2) + 1, col: col + 1)
        }
    }
    
    func checkWall(row: Int, col: Int, direction: Direction) -> Bool {
        let wall = getWall(row: row, col: col, direction: direction)
        return maze[wall.row][wall.col]
    }
    
    func drawMaze() {
        
        // Player
        
        let offset: CGFloat = 5.0
        
        let player = SKShapeNode(rectOf: CGSize(width: wallLength - 2 * offset,
                                                height: wallLength - 2 * offset))
        player.position = CGPoint(x: frame.midX, y: frame.midY)
        player.fillColor = SKColor.darkGray
        
        addChild(player)
        
        // Player coordinate
        
        playerCoord = (colNumber / 2, rowNumber / 2)
        
        // Maze
        
        let width: CGFloat = CGFloat(colNumber) * wallLength
        let height: CGFloat = CGFloat(rowNumber) * wallLength
        
        world = SKShapeNode(rectOf: CGSize(width: width, height: height))
        world?.strokeColor = SKColor.clear
        world?.fillColor = SKColor.clear
        world?.position = CGPoint(x: frame.midX, y: frame.midY)
        
        worldPosition = world?.position
       
        for row in 0..<maze.count {
            let colCount = maze[row].count
            for col in 0..<colCount {
                if maze[row][col] {
                    drawWall(row, col)
                }
            }
        }
        
        addChild(world!)
    }
    
    func drawWall(_ row: Int, _ col: Int) {
        
        let height = CGFloat(rowNumber) * wallLength / 2.0
        let width = CGFloat(colNumber) * wallLength / 2.0
        let horizontal = (row % 2) == 0
        
        let path = CGMutablePath()
        
        if horizontal {
            let start = CGPoint(x: CGFloat(col) * wallLength - width,
                                y: height - wallLength * CGFloat(row) / 2)
            var end = start
            end.x += wallLength
                
            path.move(to: start)
            path.addLine(to: end)
        } else {
            let start = CGPoint(x: CGFloat(col) * wallLength - width,
                                y: height - wallLength * CGFloat(row - 1) / 2)
            var end = start
            end.y -= wallLength
            
            path.move(to: start)
            path.addLine(to: end)
        }
        
        let wall = SKShapeNode(path: path)
        wall.strokeColor = SKColor.darkGray
        
        world?.addChild(wall)
    }
    
    func setupAccelerometerControl() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] (data, error) in
                if let acceleration = data?.acceleration {
                    if self?.world != nil {
                        let currentWorldPositionX = self?.world!.position.x
                        let currentWorldPositionY = self?.world!.position.y
                        
                        self?.worldDestanationX = currentWorldPositionX! + CGFloat(acceleration.x * 1000)
                        self?.worldDestanationY = currentWorldPositionY! + CGFloat(acceleration.y * 1000)
                    }
                }
            }
        }
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        //let action = SKAction.move(to: CGPoint(x: worldDestanationX, y: worldDestanationY), duration: 1)
        //world?.run(action)
        if playerCoord.row == -1 || playerCoord.row == rowNumber {
            showMaze()
        }
    }
    
    // Control
    
    var worldPosition: CGPoint!

    var isHorizontalMove: Bool?
    
    var playerCoord: Cell = (0, 0)
    
    var movePlayerCoord: Cell = (0, 0)
    var moveWorldPosition: CGPoint!
    
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
    
    func makeMoveTemp(direction: Direction) {
        switch direction {
        case .up:
            movePlayerCoord.row -= 1
        case .down:
            movePlayerCoord.row += 1
        case .left:
            movePlayerCoord.col -= 1
        case .right:
            movePlayerCoord.col += 1
        }
    }
    
    func moveDirection(from translation: CGPoint) -> Direction {
        if abs(translation.x) > abs(translation.y) {
            if translation.x > 0 {
                return .right
            } else {
                return .left
            }
        } else {
            if translation.y > 0 {
                return .up
            } else {
                return .down
            }
        }
    }
    
    func checkPlayer(direction: Direction) -> Bool {
        return !checkWall(row: playerCoord.row, col: playerCoord.col, direction: direction)
        //return !checkWall(row: movePlayerCoord.row, col: movePlayerCoord.col, direction: direction)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //worldPosition = world?.position
        movePlayerCoord = playerCoord
        moveWorldPosition = worldPosition
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            let position = touch.location(in: self)
            let previousPosition = touch.previousLocation(in: self)
            
            let translation = CGPoint(x: position.x - previousPosition.x,
                                      y: position.y - previousPosition.y)
            
            var moveTranslation = CGPoint(x: world!.position.x - worldPosition.x,
                                          y: world!.position.y - worldPosition.y)
            
            let direction = moveDirection(from: translation)
            let isHorizontal = direction.isHorizontal()
            
            if isHorizontalMove == nil {
                isHorizontalMove = isHorizontal
            }
            
            // first - make move
            // second - check
            
            var tempWorldPosition = world!.position
            
            if checkPlayer(direction: direction) {
                if isHorizontal == isHorizontalMove {
                    if isHorizontal {
                        
                        
                        
                        if abs(moveTranslation.x) > wallLength {
                            makeMove(direction: direction)
                            if translation.x > 0 {
                                worldPosition.x -= wallLength
                            } else {
                                worldPosition.x += wallLength
                            }
                            print(direction)
                            print(playerCoord)
                        }
                        
                        world!.position.x -= translation.x
                        
                        /// !!!
                        
                        tempWorldPosition.x -= translation.x
                        moveTranslation = CGPoint(x: tempWorldPosition.x - worldPosition.x,
                                                  y: tempWorldPosition.y - worldPosition.y)
                        
                        if abs(moveTranslation.x) > wallLength / 3 {
                            // check again
                        }
                        
                        
                        
                        
                        
                    } else {
                        world!.position.y -= translation.y
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isHorizontalMove != nil {
            
            let translation = CGPoint(x: world!.position.x - worldPosition.x,
                                      y: world!.position.y - worldPosition.y)
            
            if isHorizontalMove! {
                if abs(translation.x) > wallLength / 3 {
                    makeMove(direction: moveDirection(from: translation).inverse())
                    if translation.x > 0 {
                        worldPosition.x += wallLength
                    } else {
                        worldPosition.x -= wallLength
                    }
                }
            } else {
                if abs(translation.y) > wallLength / 3 {
                    makeMove(direction: moveDirection(from: translation).inverse())
                    if translation.y > 0 {
                        worldPosition.y += wallLength
                    } else {
                        worldPosition.y -= wallLength
                    }
                }
            }
            
            
            print(playerCoord)
            
            world!.position = worldPosition
            isHorizontalMove = nil
        }
    }
    
}
