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

class GameScene: SKScene {
    
    var rowNumber: Int = 5
    var colNumber: Int = 5
    
    var world: MapNode?
    
    var motionManager = CMMotionManager()
    
    var worldDestanationX: CGFloat = 0.0
    var worldDestanationY: CGFloat = 0.0
    
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor.white
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        
        //drawPlayer()
        showMap()
    }
    
    func drawPlayer() {
        
        let offset: CGFloat = 5.0
        
        let player = SKShapeNode(rectOf: CGSize(width:  UI.wallLength - 2 * offset,
                                                height: UI.wallLength - 2 * offset))
        player.position = CGPoint(x: frame.midX, y: frame.midY)
        player.fillColor = SKColor.darkGray
        
        addChild(player)
    }
    
    func showMap() {
        
        world?.removeFromParent()
        
        world = MapNode(row: 13, col: 13)
        world!.position = CGPoint(x: frame.midX, y: frame.midY)
        world!.savedPosition = world?.position
        
        world!.addMazeNode(node: MazeNode(row: 5, col: 5, pos: Cell(3, 3)))
        world!.addMazeNode(node: MazeNode(row: 3, col: 3, pos: Cell(8, 8)))
        world!.addMazeNode(node: MazeNode(row: 3, col: 3, pos: Cell(8, 2)))
        
        world!.addLifeNode(node: LifeNode(row: 5, col: 5, pos: Cell(3, 9)))
        
        world!.drawPlayer()
        
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
    }
    
    // Control

    var currentDirection: Direction?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            let position = touch.location(in: self)
            let previousPosition = touch.previousLocation(in: self)
            
            let translation = position - previousPosition
            
            let direction = translation.direction
            
            if currentDirection == nil {
                if world!.checkPlayer(direction: direction) {
                    currentDirection = direction
                } else if world!.checkPlayer(direction: translation.secondDirection) {
                    currentDirection = translation.secondDirection
                }
            }
            
            if currentDirection != nil {
                
                var tempWorldPosition = world!.position
                let directionComponent = translation.component(using: currentDirection!)
                
                if !directionComponent.equalTo(CGPoint.zero) {
                    
                    tempWorldPosition -= directionComponent
                    
                    let moveTranslation = world!.savedPosition - tempWorldPosition
                    let moveLength = moveTranslation.componentLength(using: currentDirection!)
                    
                    if moveLength >= UI.wallLength {
                        world!.makeMove(direction: moveTranslation.direction)
                        world!.position = world!.savedPosition
                        currentDirection = nil
                    } else if moveLength != 0.0 && moveTranslation.direction != currentDirection! {
                        world!.position = world!.savedPosition
                        currentDirection = nil
                    } else {
                        world!.move(tempWorldPosition, direction: directionComponent.direction)
                    }
                }
                
            } else {
                //print("NO DIRECTION: \(direction)")
            }            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentDirection != nil {
            
            let translation = world!.savedPosition - world!.position
            
            if translation.componentLength(using: currentDirection!) > UI.wallLength / 3 {
                world!.makeMove(direction: currentDirection!) ///!!!
            }
            
            let action = SKAction.move(to: world!.savedPosition, duration: 0.2)
            world!.run(action)
            
            currentDirection = nil
        }
    }
    
}
