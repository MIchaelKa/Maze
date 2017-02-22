//
//  LifeNode.swift
//  Maze
//
//  Created by Michael Kalinin on 20/02/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

import Foundation
import SpriteKit

class LifeNode: SKShapeNode {
    
    let cornerRadius: CGFloat = 3.0
    
    var rowNumber: Int
    var colNumber: Int
    
    var width: CGFloat
    var height: CGFloat
    
    var mapPosition: Cell
    
    var cells: [[Bool]] = []
    
    var aliveCells: [LifeCellNode] = []
    
    var cellsToShow: [LifeCellNode] = []
    var cellsToHide: [LifeCellNode] = []
    
    var timer: Timer?
    
    init(row: Int, col: Int, pos: Cell) {
        
        mapPosition = pos
        
        rowNumber = row
        colNumber = col
        
        width = CGFloat(row) * UI.wallLength
        height = CGFloat(col) * UI.wallLength
        
        super.init()
        
        let rect = CGRect(origin: CGPoint(x: -(width / 2.0), y: -(height / 2.0)),
                          size: CGSize(width: width, height: height))
        
        path = CGPath(rect: rect, transform: nil)
        
        strokeColor = SKColor.lightGray
        fillColor = SKColor.clear
        
        //drawGrid()
        
        cells = createGlider()
        
        show()
        startTimer()
    }
    
    func createClearGeneration() -> [[Bool]] {
        
        var generation = [[Bool]]()
        
        for _ in 0..<rowNumber {
            let row = Array(repeating: false, count: colNumber)
            generation.append(row)
        }
        
        return generation
    }
    
    func createGlider() -> [[Bool]] {
        
        var cells = createClearGeneration()
        
        cells[1][2] = true
        cells[2][3] = true
        cells[3][1] = true
        cells[3][2] = true
        cells[3][3] = true
        
        return cells
    }
    
    func createBlinker() -> [[Bool]] {
        
        var cells = createClearGeneration()
        
        cells[1][2] = true
        cells[2][2] = true
        cells[3][2] = true
        
        cellsToShow.append(LifeCellNode(cell: Cell(1, 2)))
        cellsToShow.append(LifeCellNode(cell: Cell(2, 2)))
        cellsToShow.append(LifeCellNode(cell: Cell(3, 2)))
        
        return cells
    }
    
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.showNextGeneration), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func show() {
        
        for cell in cellsToHide {
            cell.hide()
        }
        
        for cell in cellsToShow {
            addChild(cell)
            cell.show()
        }
        
        aliveCells.append(contentsOf: cellsToShow)
        
        cellsToShow.removeAll()
        cellsToHide.removeAll()
    }
    
    func showNextGeneration() {
        
        var next = createClearGeneration()
        
        for i in 0..<rowNumber {
            for j in 0..<colNumber {
                
                let neighbours = cell(i-1, j-1) +
                    cell(i-1, j) +
                    cell(i-1, j+1) +
                    cell(i, j-1) +
                    cell(i, j+1) +
                    cell(i+1, j-1) +
                    cell(i+1, j) +
                    cell(i+1, j+1)
                
                if neighbours == 3 || (neighbours == 2 && cells[i][j]) {
                    next[i][j] = true
                }
                
                if cells[i][j] && !next[i][j] {
                    if let cell = aliveLifeCell(row: i, col: j) {
                        cellsToHide.append(cell)
                    }
                }
                
                if !cells[i][j] && next[i][j] {
                    cellsToShow.append(lifeCell(row: i, col: j))
                }
            }
        }
        
        cells = next
        
        show()
    }
    
    func cell(_ row: Int, _ col: Int) -> Int {
        let cell = cells[checkRow(row: row)][checkCol(col: col)]
        return Int(cell as NSNumber)
    }
    
    func checkRow(row: Int) -> Int {
        
        if row < 0 {
            return rowNumber - 1
        }
        
        if row > (rowNumber - 1) {
            return 0
        }
        
        return row
    }
    
    func checkCol(col: Int) -> Int {
        
        if col < 0 {
            return colNumber - 1
        }
        
        if col > (colNumber - 1) {
            return 0
        }
        
        return col
    }
    
    func aliveLifeCell(row: Int, col: Int) -> LifeCellNode? {
        
        let cell = Cell(row, col)
        
        for (index, alive) in aliveCells.enumerated() {
            if alive.cell == cell {
                return aliveCells.remove(at: index)
            }
        }
        
        return nil
    }
    
    func lifeCell(row: Int, col: Int) -> LifeCellNode {        
        
        let cellNode = LifeCellNode(cell: Cell(row, col))
        cellNode.position = CGPoint(x: CGFloat(col) * UI.wallLength - (width / 2.0) + UI.wallLength / 2,
                                y: (height / 2.0) - CGFloat(row) * UI.wallLength - UI.wallLength / 2)
        return cellNode
    }
    
    func drawGrid() {
        
        for row in 0...rowNumber {
            let start = CGPoint(x: -(width / 2.0),
                                y: (height / 2.0) - UI.wallLength * CGFloat(row))
            var end = start
            end.x += width
            
            drawLine(start: start, end: end)
        }
        
        for col in 0...colNumber {
            let start = CGPoint(x: UI.wallLength * CGFloat(col) - (width / 2.0),
                                y: (height / 2.0))
            var end = start
            end.y -= height
            
            drawLine(start: start, end: end)
        }
    }
    
    func drawLine(start: CGPoint, end: CGPoint) {
        
        let path = CGMutablePath()
        
        path.move(to: start)
        path.addLine(to: end)
        
        let line = SKShapeNode(path: path)
        line.strokeColor = SKColor.lightGray
        
        self.addChild(line)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
