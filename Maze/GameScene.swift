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
    
    let wallLength: CGFloat = 40.0 // TODO: shared 
    
    var rowNumber: Int = 5
    var colNumber: Int = 5
    
    var world: MazeNode?
    
    var motionManager = CMMotionManager()
    
    var worldDestanationX: CGFloat = 0.0
    var worldDestanationY: CGFloat = 0.0
    
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor.white
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        
        drawPlayer()
        drawMaze()
    }
    
    func drawPlayer() {
        
        let offset: CGFloat = 5.0
        
        let player = SKShapeNode(rectOf: CGSize(width: wallLength - 2 * offset,
                                                height: wallLength - 2 * offset))
        player.position = CGPoint(x: frame.midX, y: frame.midY)
        player.fillColor = SKColor.darkGray
        
        addChild(player)
    }
        
    func drawMaze() {
        
        world?.removeFromParent()
        
        world = MazeNode(row: rowNumber, col: colNumber)
        
        world?.drawMaze()
        world?.position = CGPoint(x: frame.midX, y: frame.midY)
        worldPosition = world?.position
        
        addChild(world!)
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
        if world!.isPlayerOut() {
            rowNumber += 2
            colNumber += 2
            drawMaze()
        }
    }
    
    // Control
    
    var worldPosition: CGPoint!
    var isHorizontalMove: Bool?

    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            let position = touch.location(in: self)
            let previousPosition = touch.previousLocation(in: self)
            
            let translation = CGPoint(x: position.x - previousPosition.x,
                                      y: position.y - previousPosition.y)
            
            
            let direction = moveDirection(from: translation)
            let isHorizontal = direction.isHorizontal()
            
            if isHorizontalMove == nil {
                isHorizontalMove = isHorizontal
            }
            
            var tempWorldPosition = world!.position
            
            if world!.checkPlayer(direction: direction) {
                if isHorizontal == isHorizontalMove {
                    if isHorizontal {
                        
                        tempWorldPosition.x -= translation.x

                        let moveTranslation = CGPoint(x: tempWorldPosition.x - worldPosition.x,
                                                      y: tempWorldPosition.y - worldPosition.y)
                        
                        
                        if abs(moveTranslation.x) >= wallLength {
                            world!.makeMove(direction: direction)
                            if translation.x > 0 {
                                worldPosition.x -= wallLength
                            } else {
                                worldPosition.x += wallLength
                            }
                            
                            world!.position = worldPosition
                            isHorizontalMove = nil
                            
                        } else {
                            world!.position.x -= translation.x
                        }
                        
                        
                    } else {
                        
                        tempWorldPosition.y -= translation.y
                        
                        let moveTranslation = CGPoint(x: tempWorldPosition.x - worldPosition.x,
                                                      y: tempWorldPosition.y - worldPosition.y)
                        
                        if abs(moveTranslation.y) >= wallLength {
                            world!.makeMove(direction: direction)
                            if translation.y > 0 {
                                worldPosition.y -= wallLength
                            } else {
                                worldPosition.y += wallLength
                            }
                            
                            world!.position = worldPosition
                            isHorizontalMove = nil
                            
                        } else {
                            world!.position.y -= translation.y
                        }
                        
                    }
                }
            } else {
                print(direction)
            }
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isHorizontalMove != nil {
            
            let translation = CGPoint(x: world!.position.x - worldPosition.x,
                                      y: world!.position.y - worldPosition.y)
            
            if isHorizontalMove! {
                if abs(translation.x) > wallLength / 3 {
                    world!.makeMove(direction: moveDirection(from: translation).inverse())
                    if translation.x > 0 {
                        worldPosition.x += wallLength
                    } else {
                        worldPosition.x -= wallLength
                    }
                }
            } else {
                if abs(translation.y) > wallLength / 3 {
                    world!.makeMove(direction: moveDirection(from: translation).inverse())
                    if translation.y > 0 {
                        worldPosition.y += wallLength
                    } else {
                        worldPosition.y -= wallLength
                    }
                }
            }
            
            let action = SKAction.move(to: worldPosition, duration: 0.2)
            world!.run(action)
            
            //world!.position = worldPosition
            
            isHorizontalMove = nil
        }
    }
    
}
