//
//  GameScene.swift
//  CameraController
//
//  Created by scauos on 2018/3/19.
//  Copyright © 2018年 scauos. All rights reserved.
//

import SceneKit

class GameScene: SCNScene {

    var helper = GameHelper()

    var sphereNode: SCNNode!

    var configurator: Configurator? {
        didSet {
            resetToInitialState()
        }
    }

    var cameraDircetion = Direction.forward
    var currentLocation = Location(z: 0, x: 0)

    var animationQueue = Queue<Direction>()

    var moveDuration = 0.7

    private var confettiParticleSystem: SCNParticleSystem!


    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }

    func resetToInitialState() {
        removeAllParticleSystems()
        rootNode.childNodes { (node, _) -> Bool in
            node.removeFromParentNode()
            return true
        }
        if let configurator = configurator {
            NSLog("iii")
            helper.checkQueue = configurator.checkQueue
            positionCamera(with: configurator)
            configurewelComeScene(with: configurator)
        }
    }
    //MARK: Camera
    var cameraYHandle = SCNNode()
    var cameraXHandle = SCNNode()
    var cameraNode = SCNNode()
    var camera = SCNCamera()

    func positionCamera(with configurator: Configurator) {
        camera.zFar = 100
        camera.zNear = 0.3

        cameraNode.camera = camera
        cameraNode.name = "camera"
        cameraNode.position = SCNVector3Zero
        cameraNode.eulerAngles = SCNVector3Zero

        rootNode.addChildNode(cameraYHandle)
        cameraYHandle.position = SCNVector3Make(0, configurator.welcomeCameraHeight, 0)
        cameraYHandle.eulerAngles = SCNVector3Make(-.pi/2, 0, 0)
        cameraYHandle.addChildNode(cameraXHandle)
        cameraYHandle.name = "camera"
        cameraXHandle.position = SCNVector3Zero
        cameraXHandle.eulerAngles = SCNVector3Zero
        cameraXHandle.name = "camera"
        cameraXHandle.addChildNode(cameraNode)
        cameraNode.position = SCNVector3Zero
        cameraNode.eulerAngles = SCNVector3Zero


        lightingEnvironment.contents = UIImage(named: "art.scnassets/img_skybox.jpg")
        background.contents = UIImage(named: "art.scnassets/img_skybox.jpg")
    }

    func panCamera(_ direction: float2, firstPan: inout Bool) {

        var directionToPan = direction
        directionToPan *= float2(1.0, -1.0)
        let F = SCNFloat(0.005)
        if firstPan {
            cameraXHandle.rotation = SCNVector4(x: 1.0, y: 0.0, z: 0.0, w: 2 * .pi)
            cameraYHandle.rotation = SCNVector4(x: 0.0, y: 1.0, z: 0.0, w: 0)
            firstPan = false
            return
        }
        SCNTransaction.animateWithDuration(0.0) {
            if self.cameraYHandle.rotation.y < 0 {
                self.cameraYHandle.rotation = SCNVector4(0, 1, 0, -self.cameraYHandle.rotation.w)
            }

            if self.cameraXHandle.rotation.x < 0 {
                self.cameraXHandle.rotation = SCNVector4(1, 0, 0, -self.cameraXHandle.rotation.w)
            }

        }
        // Update the camera position with some inertia.
        SCNTransaction.animateWithDuration(0.5, timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)) {
            self.cameraYHandle.rotation = SCNVector4(0, 1, 0, self.cameraYHandle.rotation.y * (self.cameraYHandle.rotation.w - SCNFloat(directionToPan.x) * F))
            self.cameraXHandle.rotation = SCNVector4(1, 0, 0, min(max(self.cameraXHandle.rotation.w + SCNFloat(directionToPan.y) * F, 5.5), 7.0))
        }

        guard let direction = getDirection(with: cameraYHandle.eulerAngles) else {
            cameraDircetion = .forward
            return
        }

        cameraDircetion = direction
    }

    func getDirection(with eulerAngles: SCNVector3) -> Direction? {
        let degree = eulerAngles.y.radiansToDegrees
        let xDegree = eulerAngles.x.radiansToDegrees
        if eulerAngles.x.radiansToDegrees <= 90 && eulerAngles.x.radiansToDegrees >= -90 {
            if degree > -45.0 && degree <= 45.0 {
                return Direction.forward //up
            } else if (degree > 45 && degree <= 90) || Int(degree) == -90 {
                return Direction.left
            } else if (degree > -90 && degree <= -45) || Int(degree) == 90 { // -90 ~ -45
                return Direction.right
            }
            return nil
        }
        else if Int(xDegree) == 360 && Int(degree) == -90 {
            return  Direction.left
        }
        else if Int(xDegree) == 360 && Int(degree) == 90 {
            return Direction.right
        }
        else { // == .pi
            if degree >= 45.0 && degree < 90 {
                return Direction.left
            } else if degree >= -45 && degree < 45 {
                return Direction.backward //down
            } else if degree > -90 && degree < -45 {
                return Direction.right
            }
            return nil
        }
    }

    func shackCamera() {
        popNode.runAction(SCNAction.playAudio(popSource, waitForCompletion: false))
        let shackDuraction = 0.05
        let a = cameraNode.eulerAngles
        cameraNode.camera?.motionBlurIntensity = 0.5
        let action = SCNAction.sequence([SCNAction.rotateBy(x: 0, y: CGFloat(5).degreesToRadians, z: 0, duration: shackDuraction),SCNAction.rotateBy(x: 0, y: CGFloat(-10).degreesToRadians, z: 0, duration: shackDuraction),SCNAction.rotateBy(x: 0, y: CGFloat(5).degreesToRadians, z: 0, duration: shackDuraction)])
        let actions = SCNAction.repeat(action, count: 4)
        actions.timingMode = .easeOut
        cameraNode.runAction(actions) {
            self.cameraNode.eulerAngles = a
            self.cameraNode.camera?.motionBlurIntensity = 0
        }
        //showFailMessage()
    }

    func moveSphere(with direction: Direction) {
        let configurator = self.configurator!
        switch direction {
        case .forward:
            if currentLocation.z-1 >= 0 {
                if configurator.Matrix[currentLocation.z-1][currentLocation.x] == 0 {
                    currentLocation.z -= 1
                    animationQueue.enqueue(element: .forward)
                    cameraYHandle.runAction(SCNAction.move(by: SCNVector3Make(0, 0, -1), duration: moveDuration), completionHandler: {
                    })
                } else {
                    shackCamera()
                }
            } else { shackCamera() }
        case .left:
            if currentLocation.x-1 >= 0 {
                if configurator.Matrix[currentLocation.z][currentLocation.x-1] == 0 {
                    self.currentLocation.x -= 1
                    animationQueue.enqueue(element: .left)
                    cameraYHandle.runAction(SCNAction.move(by: SCNVector3Make(-1, 0, 0), duration: moveDuration), completionHandler: {
                    })
                } else {
                    shackCamera()
                }
            } else {
                shackCamera()
            }
        case .backward:
            if currentLocation.z+1 < configurator.Matrix.count {
                if configurator.Matrix[currentLocation.z+1][currentLocation.x] == 0 {
                    self.currentLocation.z += 1
                    animationQueue.enqueue(element: .backward)
                    cameraYHandle.runAction(SCNAction.move(by: SCNVector3Make(0, 0, 1), duration: moveDuration), completionHandler: {
                    })
                } else {
                    shackCamera()
                }
            } else {
                shackCamera()
            }
        case .right:
            if currentLocation.x+1 < configurator.Matrix.count {
                if configurator.Matrix[currentLocation.z][currentLocation.x+1] == 0 {
                    self.currentLocation.x += 1
                    animationQueue.enqueue(element: .right)
                    cameraYHandle.runAction(SCNAction.move(by: SCNVector3Make(1, 0, 0), duration: moveDuration), completionHandler: {
                    })
                } else {
                    shackCamera()
                }
            } else {
                shackCamera()
            }
        }
        if currentLocation == configurator.EndPoint {
            presentWinningScene()
        }
    }

    func presentWinningScene() {
        let scale = SCNMatrix4MakeScale(1, 1, 1)
        addParticleSystem(confettiParticleSystem, transform: scale)
        winningNode.runAction(SCNAction.playAudio(winningSource, waitForCompletion: false))
        helper.state = .gameWin
        SCNTransaction.animateWithDuration(0.8, timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut), completionBlock: {
            self.sphereNode.isHidden = false
            let actions = self.helper.getActions(with: self.animationQueue.getAll())
            self.sphereNode.runAction(SCNAction.repeatForever(actions), forKey: "sphere")
        }, animations: {
            self.cameraNode.eulerAngles = SCNVector3Zero
            self.cameraNode.position = SCNVector3Zero

            self.cameraXHandle.eulerAngles = SCNVector3Zero
            self.cameraXHandle.position = SCNVector3Zero

            self.cameraYHandle.position = SCNVector3Make(0, self.configurator!.cameraHeight, 0)
            self.cameraYHandle.eulerAngles = SCNVector3Make(-.pi/2, 0, 0)

        })
    }

    //MARK: Floor
    func positionFloor(with matrix: [[Int]]) {
        let plane = SCNPlane(width: 1, height: 1)
        plane.firstMaterial?.diffuse.contents = UIImage(named: "taco_difuse.jpg")
        for z in 0 ... matrix.count - 1 {
            for x in 0 ... matrix[0].count - 1 {
                let planeNode = SCNNode(geometry: plane)
                planeNode.eulerAngles = SCNVector3Make(-.pi/2, 0, 0)
                let zPosition = Float(z - matrix.count / 2)
                let xPosition = Float(x - matrix.count / 2)
                let position = SCNVector3Make(xPosition, 0.01, zPosition)
                planeNode.position = position
                rootNode.addChildNode(planeNode)
            }
        }
    }
    //MARK: Boxs
    func positionBoxs(with matrix: [[Int]], entrance: Location) {
        var position: SCNVector3!
        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
        box.firstMaterial?.lightingModel = .physicallyBased
        box.firstMaterial?.metalness.contents = UIImage(named: "art.scnassets/gold-scuffed-metal.png")
        box.firstMaterial?.normal.contents = UIImage(named: "art.scnassets/gold-scuffed-normal.png")
        box.firstMaterial?.roughness.contents = UIImage(named: "art.scnassets/gold-scuffed-roughness.png")
        box.firstMaterial?.diffuse.contents = configurator!.boxColors.random()
        let templateNode = SCNNode(geometry: box)

        let tbBox = SCNBox(width: CGFloat(matrix.count+1), height: 1, length: 0.5, chamferRadius: 0.1)
        tbBox.firstMaterial = box.firstMaterial?.copy() as? SCNMaterial
        tbBox.firstMaterial?.diffuse.contents = UIColor.red

        let tbNode = SCNNode(geometry: tbBox)

        let topBox = tbNode.clone()
        topBox.position = SCNVector3Make(0, 0.5, Float(matrix.count/2) + 0.75)
        rootNode.addChildNode(topBox)

        let buttomBox = tbNode.clone()
        buttomBox.position = SCNVector3Make(0, 0.5, -(Float(matrix.count/2) + 0.75))
        rootNode.addChildNode(buttomBox)

        let lrBox = SCNBox(width: 0.5, height: 1, length: CGFloat(matrix.count), chamferRadius: 0.1)
        lrBox.firstMaterial = tbBox.firstMaterial?.copy() as? SCNMaterial

        let lrNode = SCNNode(geometry: lrBox)

        let leftBox = lrNode.clone()
        leftBox.position = SCNVector3Make(-(Float(matrix.count/2) + 0.75), 0.5, 0)
        rootNode.addChildNode(leftBox)

        let rightBox = lrNode.clone()
        rightBox.position = SCNVector3Make(Float(matrix.count/2) + 0.75, 0.5, 0)
        rootNode.addChildNode(rightBox)



        for z in 0 ... matrix.count-1 {
            for x in 0 ... matrix[0].count-1 {
                let zPosition = Float(z - matrix.count/2)
                let xPosition = Float(x - matrix.count/2)
                if matrix[z][x] == 1 {
                    let boxNode = templateNode.clone()
                    position = SCNVector3Make(xPosition, 0.5, zPosition)
                    boxNode.position = position
                    boxNode.name = "box"
                    rootNode.addChildNode(boxNode)
                }
            }

        }

        // position sphereNode
        let sphere = SCNSphere(radius: 0.5)
        sphere.firstMaterial = box.firstMaterial?.copy() as? SCNMaterial
        sphere.firstMaterial?.diffuse.contents = configurator!.boxColors.random()
        sphereNode = SCNNode(geometry: sphere)
        let zPosition = Float(entrance.z - matrix.count/2)
        let xPosition = Float(entrance.x - matrix.count/2)
        sphereNode.position = SCNVector3Make(xPosition, 0.5, zPosition)
        rootNode.addChildNode(sphereNode)

    }

    //MARK: initAudio

    var audioNode: SCNNode!
    var audioSource: SCNAudioSource!

    var popNode: SCNNode!
    var popSource: SCNAudioSource!

    var winningNode: SCNNode!
    var winningSource: SCNAudioSource!

    func initAudio() {
        audioSource = SCNAudioSource(named: "art.scnassets/background.mp3")!
        audioSource.loops = true
        audioSource.load()
        let player = SCNAudioPlayer(source: audioSource)
        audioNode = SCNNode()
        audioNode.addAudioPlayer(player)
        rootNode.addChildNode(audioNode)

        popSource = SCNAudioSource(named: "art.scnassets/pop.mp3")!
        popSource.loops = false
        popSource.load()
        popNode = SCNNode()
        popNode.addAudioPlayer(SCNAudioPlayer(source: popSource))
        rootNode.addChildNode(popNode)

        winningSource = SCNAudioSource(named: "art.scnassets/winning.mp3")!
        winningSource.loops = false
        winningSource.load()
        winningNode = SCNNode()
        winningNode.addAudioPlayer(SCNAudioPlayer(source: winningSource))
        rootNode.addChildNode(winningNode)
    }

    var endPointSys: SCNParticleSystem!


    func positionEndPoint(with matrix: [[Int]], endPoint: Location) {
        endPointSys = SCNParticleSystem(named: "art.scnassets/collect.scnp", inDirectory: nil)!
        let particleNode = SCNNode()
        particleNode.position = SCNVector3Make(Float(endPoint.x-matrix.count/2), 0, Float(endPoint.z-matrix.count/2))
        var particleSystemPosition = particleNode.worldTransform
        particleSystemPosition.m42 += 0.1
        addParticleSystem(endPointSys, transform: particleSystemPosition)
    }


    func configurewelComeScene(with configurator: Configurator) {

        //positionScene
        positionBoxs(with: configurator.matrix, entrance: configurator.entrance)
        positionFloor(with: configurator.matrix)
        positionEndPoint(with: configurator.matrix, endPoint: configurator.endPoint)
        confettiParticleSystem = SCNParticleSystem(named: "art.scnassets/confetti.scnp", inDirectory: nil)
        initAudio()

        sphereNode.removeAllActions()
        let (directions, _, _, _) = helper.Check(with: configurator.matrix, startPoint: configurator.entrance, endPoint: configurator.endPoint)
        if directions.count > 0 {
            print(directions)
            let directionQueue = helper.getAnimationQueue(with: directions)
            let action = helper.getSequenceActions(from: directionQueue)

            //we should  switch the directions
            let switchDirectionQueue = helper.reverseAll(directions: directionQueue)
            var actions = helper.getActions(form: switchDirectionQueue)
            actions.reverse()

            //reversed the directionQueue so it will go back
            let backAction = SCNAction.sequence(actions)

            let repeatAction = SCNAction.sequence([action, backAction])
            sphereNode.runAction(SCNAction.repeatForever(repeatAction))
            print("aabbcc")
        }
    }

    func resetGame() {
        removeAllParticleSystems()

        rootNode.childNodes { (node, _) -> Bool in
            if node.name != "camera" {
                SCNTransaction.animateWithDuration(0.5, timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut), completionBlock: {
                    node.removeFromParentNode()
                }, animations: {
                    node.opacity = 0
                })
            }
            return true
        }
        configurewelComeScene(with: configurator!)
        // not the start position
        switch helper.state {
        case .began, .gameLose, .gameWin:
            SCNTransaction.animateWithDuration(0.5, timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut), completionBlock: {
                self.helper.state = .tapToBegin
            }, animations: {
                self.cameraNode.eulerAngles = SCNVector3Zero
                self.cameraNode.position = SCNVector3Zero
                self.cameraXHandle.eulerAngles = SCNVector3Zero
                self.cameraXHandle.position = SCNVector3Zero
                self.cameraYHandle.position = SCNVector3Make(0, self.configurator!.welcomeCameraHeight, 0)
                self.cameraYHandle.eulerAngles = SCNVector3Make(-.pi/2, 0, 0)
            })
        default:
            break
        }
    }

    func gameStart() {
        removeAllParticleSystems()
        rootNode.childNodes { (node, _) -> Bool in
            if node.name != "camera" {
                SCNTransaction.animateWithDuration(0.5, timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut), completionBlock: {
                    node.removeFromParentNode()
                }, animations: {
                    node.opacity = 0
                })
            }
            return true
        }
        confiGammingScene()
    }

    func confiGammingScene() {
        guard let configurator = configurator else { return }
        positionFloor(with: configurator.Matrix)
        positionBoxs(with: configurator.Matrix, entrance: configurator.Entrance)
        positionEndPoint(with: configurator.Matrix, endPoint: configurator.EndPoint)
        currentLocation = configurator.Entrance
                confettiParticleSystem = SCNParticleSystem(named: "art.scnassets/confetti.scnp", inDirectory: nil)
                initAudio()
    }
}
