//
//  Cell.swift
//  Maze
//
//  Created by Michael Kalinin on 18/01/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

import Foundation

class Cell {
    
    var row: Int
    var col: Int
    
    init(_ row: Int, _ col: Int) {
        self.row = row
        self.col = col
    }
    
    func makeMove(to direction: Direction) {
        switch direction {
            case .up:    row -= 1
            case .down:  row += 1
            case .left:  col -= 1
            case .right: col += 1
        }
    }
    
    func getCell(from direction: Direction) -> Cell {
        let cell = Cell(row, col)
        cell.makeMove(to: direction)
        return cell
    }
    
}
