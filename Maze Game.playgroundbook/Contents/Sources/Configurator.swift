//
//  Configurator.swift
//  CameraController
//
//  Created by scauos on 2018/3/19.
//  Copyright © 2018年 scauos. All rights reserved.
//

import Foundation
import UIKit
public enum Direction: Int {
    case forward = 0
    case left
    case backward
    case right
}

extension Direction: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .forward:
            return "⬆️"
        case .backward:
            return "⬇️"
        case .left:
            return "⬅️"
        case .right:
            return "➡️"
        }
    }
}

public struct Location {
    public var x: Int
    public var z: Int
    public init(z: Int, x: Int) {
        self.x = x
        self.z = z
    }
}

extension Location: Equatable {
    public static func ==(lhs: Location, rhs: Location) -> Bool {
        if lhs.x == rhs.x && lhs.z == rhs.z { return true }
        return false
    }
}

extension Location: CustomStringConvertible {
    public var description: String {
        return "(z:\(z), x:\(x))"
    }
}
public class Configurator {

    public var boxColor: UIColor? = .gray

    public var sphereColor: UIColor? = .red

    public var gridColor: UIColor? = .blue

    public var gameTimming: Int? = 10

    public var time: Int? = 10

    public var backgroundAudio: Bool = false


    /// welcome
    public var matrix: [[Int]] = [[1,1,1,0,0],
                                  [1,0,0,0,1],
                                  [0,0,1,0,1],
                                  [1,0,1,0,0],
                                  [1,0,1,1,1]]

    public var entrance: Location = Location(z: 4, x: 1)
    public var endPoint: Location = Location(z: 3, x: 4)


    /// gamming
    public var Matrix: [[Int]] = [[1,1,1,0,0,0,0],
                                  [1,0,0,0,1,1,1],
                                  [0,0,1,0,1,1,0],
                                  [1,0,1,0,0,0,0],
                                  [1,0,1,0,1,0,1],
                                  [1,0,1,1,1,0,1],
                                  [1,0,0,0,1,0,1]]

    public var Entrance: Location = Location(z: 6, x: 3)
    public var EndPoint: Location = Location(z: 2, x: 6)

    public var cameraHeight: Float = 15.0
    public var welcomeCameraHeight: Float = 15.0

    public var checkQueue: [Direction] = [.backward, .left, .right, .forward]

    public var boxColors: [UIColor] = [#colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1) , #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1), #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1), #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]



    // SpriteScene
    public var cellCount: Int = 13

    public var ifUserTouch = true


    public init() { }

}
