//
//  Path.swift
//  Maze
//
//  Created by Michael Kalinin on 26/01/2017.
//  Copyright © 2017 Michael. All rights reserved.
//

import Foundation

class Path {
    
    var cells: [Cell] = []
    
    func clear() {
        cells.removeAll()
    }
    
    func add(path: Path) {
        for c in path.cells {
            cells.append(c)
        }
    }
    
    func add(cell: Cell) -> Bool {
        for c in cells {
            if cell.row == c.row && cell.col == c.col {
                return false
            }
        }
        cells.append(cell)
        return true
    }
    
    func addCell(row: Int, col: Int) -> Bool {
        for cell in cells {
            if cell.row == row && cell.col == col {
                return false
            }
        }
        cells.append(Cell(row, col))
        return true
    }
    
    func contains(cell: Cell) -> Bool {
        for c in cells {
            if cell.row == c.row && cell.col == c.col {
                return true
            }
        }
        return false
    }
    
    func contains(row: Int, col: Int) -> Bool {
        for cell in cells {
            if cell.row == row && cell.col == col {
                return true
            }
        }
        return false
    }
    
}
