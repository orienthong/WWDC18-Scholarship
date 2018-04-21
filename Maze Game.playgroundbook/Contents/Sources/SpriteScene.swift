//
//  SpriteScene.swift
//  CameraController
//
//  Created by scauos on 2018/3/30.
//  Copyright © 2018年 scauos. All rights reserved.
//

import UIKit
import SpriteKit

enum State {
    case wall
    case entrence
    case endpoint
    case road
}


class SpriteScene: SKScene {

    var state: State = .road
    var hadEntrence = false
    var hadEndPoint = false
    var entrence = Location(z: -1, x: -1)
    var endPoint = Location(z: -1, x: -1)


    var configurator: Configurator? {
        didSet {
            resetToInitialState()
        }
    }

    var matrix: [[Int]]!
    private var nodeToLocation = [SKSpriteNode : Location]()



    override init() {
        super.init()
    }

    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
    }

    override func didMove(to view: SKView) {
        print("didMove")
        print(size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        if let configurator = configurator {
            setUpCells(with: configurator)
        }
    }

    func resetToInitialState() {

        matrix = [[Int]](repeating: [Int](repeating: 1, count: configurator!.cellCount), count: configurator!.cellCount)
        configurator?.Matrix = matrix

        removeAllChildren()


    }

    func toPosition(with location: Location, cellWidth: CGFloat) -> CGPoint {
        return CGPoint(x: CGFloat(location.x - configurator!.cellCount / 2) * cellWidth , y: CGFloat(location.z - configurator!.cellCount / 2) * cellWidth * -1.0)
    }

    func setUpCells(with configurator: Configurator) {


        guard configurator.cellCount % 2 == 1 else { return }

        let cellWidth = size.width / CGFloat(configurator.cellCount)

        for z in 0 ... configurator.cellCount-1 {
            for x in 0 ... configurator.cellCount-1 {
                let node = SKSpriteNode()
                node.position = toPosition(with: Location(z: z, x: x), cellWidth: cellWidth)

                node.size = CGSize(width: cellWidth - 0.1, height: cellWidth - 0.1)
                node.texture = SKTexture(image: UIImage(named: "wall.png")!)

                nodeToLocation[node] = Location(z: z, x: x)
                addChild(node)



            }
        }


    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print(state)
        for touch in touches {
            let locationOfTouch = touch.location(in: self)

            if let node = atPoint(locationOfTouch) as? SKSpriteNode {
                let x = nodeToLocation[node]!.z
                let y = nodeToLocation[node]!.x
                let location = Location(z: x, x: y)

                switch state {
                case .endpoint:
                    if !hadEndPoint {
                        node.texture = SKTexture(image: UIImage(named: "endpoint.png")!)
                        hadEndPoint = true
                        endPoint = location
                        configurator!.EndPoint = endPoint
                        matrix[x][y] = 0
                    }
                    break
                case .entrence:
                    if !hadEntrence {
                        node.texture = SKTexture(image: UIImage(named: "entrence.png")!)
                        hadEntrence = true
                        entrence = location
                        configurator!.Entrance = entrence
                        matrix[x][y] = 0
                    }
                    break
                case .wall:
                    node.texture = SKTexture(image: UIImage(named: "wall.png")!)
                    matrix[x][y] = 1
                    if endPoint == location {
                        hadEndPoint = false
                    }
                    else if entrence == location {
                        hadEntrence = false
                    }

                case .road:
                    node.texture = SKTexture(image: UIImage(named: "road.png")!)
                    node.color = .cyan
                    matrix[x][y] = 0
                    if endPoint == location {
                        hadEndPoint = false
                    }
                    else if entrence == location {
                        hadEntrence = false
                    }

                }
            }

        }

    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        for touch in touches {
            let locationOfTouch = touch.location(in: self)

            if let node = atPoint(locationOfTouch) as? SKSpriteNode {
                let x = nodeToLocation[node]!.z
                let y = nodeToLocation[node]!.x
                let location = Location(z: x, x: y)

                switch state {
                case .wall:
                    node.texture = SKTexture(image: UIImage(named: "wall.png")!)
                    matrix[x][y] = 1
                    if endPoint == location {
                        hadEndPoint = false
                    }
                    else if entrence == location {
                        hadEntrence = false
                    }

                case .road:
                    node.texture = SKTexture(image: UIImage(named: "road.png")!)
                    matrix[x][y] = 0
                    if endPoint == location {
                        hadEndPoint = false
                    }
                    else if entrence == location {
                        hadEntrence = false
                    }
                default:
                    break
                }
            }

        }

    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        configurator?.Matrix = matrix
    }



}
