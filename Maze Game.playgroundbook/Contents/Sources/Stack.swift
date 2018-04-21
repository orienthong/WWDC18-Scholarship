//
//  Stack.swift
//  MazeGame
//
//  Created by Hao Dong on 29/03/2017.
//  Copyright © 2017 Hao Dong. All rights reserved.
//

import Foundation


public struct Stack<T> {
    private var array = [T]()
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public var count: Int {
        return array.count
    }
    
    public mutating func push(element: T) {
        array.append(element)
    }
    
    public mutating func pop() -> T? {
        if isEmpty {
            return nil
        } else {
            return array.removeLast()
        }
    }
    
    public mutating func push(elements: [T]) {
        for t in elements {
            array.append(t)
        }
    }
    
    public func peek() -> T? {
        return array.first
    }
}
