import SceneKit
import UIKit
import PlaygroundSupport
public class BFSGameVC: UIViewController {

    var firstPan: Bool = false

    var helper = GameHelper()
    public var checkQueue: [Direction]!

    var sceneView: SCNView!
    var scene: SCNScene!

    var matrix = [[0,0,0,1,0,0,1,0,0,0,0,1,0,1,0],
                  [0,1,0,1,0,1,1,1,1,0,0,1,0,1,0],
                  [0,1,0,0,0,0,0,0,1,0,1,1,0,1,1],
                  [1,1,1,0,1,1,1,0,1,0,0,0,0,0,0],
                  [0,0,0,0,0,1,0,0,1,1,1,1,0,1,0],
                  [1,0,1,1,0,0,1,0,1,0,0,0,0,1,0],
                  [0,0,1,0,0,1,1,1,1,0,1,0,0,1,0],
                  [1,0,1,0,0,0,1,0,1,1,1,0,1,1,1],
                  [1,0,1,0,1,0,1,0,0,0,1,0,0,0,0],
                  [1,0,1,1,1,0,1,1,0,1,0,0,1,1,0],
                  [0,0,0,1,1,0,0,0,0,1,1,1,0,0,0],
                  [1,1,0,1,0,0,1,0,0,0,0,1,1,1,0],
                  [0,0,0,1,1,1,1,1,1,0,0,0,0,1,0],
                  [0,1,0,1,0,0,0,0,1,0,1,1,0,0,0],
                  [0,1,0,0,0,1,0,0,1,0,0,0,0,0,0]]

    var entrence: Location = Location(z: 14, x: 0)
    var endPoint = Location(z: 0, x: 12)

    var sphereNode = SCNNode()

    var cameraButton: UIButton!

    var dismissView: RenderEffectView!

    /// if use dissmiss button
    var loadDismissView = false


    internal var panningTouch: UITouch?
    var cameraYHandle = SCNNode()
    var cameraXHandle = SCNNode()
    var cameraNode = SCNNode()

    var inSky = true

    var enQueuesCoder: DispatchSourceTimer? = nil
    var deQueueCoder: DispatchSourceTimer? = nil

    var defaultNodes: SCNNode!
    var deQueueNodes: SCNNode!
    var queueNodes: SCNNode!

    var defaultColor: UIColor! = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
    var deQueueColor: UIColor! = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    var enQueueColor: UIColor! = .red

    var duraction: Float = 0.5 // each step 1 s


    func resetInit() {

        enQueuesCoder?.cancel()
        deQueueCoder?.cancel()

        scene.removeAllParticleSystems()
        scene.rootNode.childNodes { (node, _) -> Bool in
            if node.name == "boxs" || node.name == "defaultNodes" || node.name == "deQueueNodes" || node.name == "queueNodes"
            {
                SCNTransaction.animateWithDuration(0.8, completionBlock: {
                    node.removeFromParentNode()
                }) {
                    node.opacity = 0
                }
            }
            return true
        }
        sphereNode.removeFromParentNode()
        positionBoxs()
        positionFloor(with: matrix)
        positionEndPointSys()

        animateSphere()
        if !inSky { // on the floor
            cameraYHandle.removeAction(forKey: "camera")
            cameraButton.isEnabled = false
            SCNTransaction.animateWithDuration(2.0, timingFunction: nil, completionBlock: {
                self.cameraButton.isEnabled = true
            }, animations: {
                cameraYHandle.position = SCNVector3Make(0, Float(matrix.count*2), 0)
                cameraYHandle.eulerAngles = SCNVector3Make(Float(-90).degreesToRadians, 0, 0)
                cameraXHandle.position = SCNVector3Zero
                cameraXHandle.eulerAngles = SCNVector3Zero
                cameraNode.position = SCNVector3Zero
                cameraNode.eulerAngles = SCNVector3Zero
            })
            inSky = true
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        helper.checkQueue = checkQueue
        scene = SCNScene()
        setUpView()
        scene.lightingEnvironment.contents = UIImage(named: "art.scnassets/img_skybox.jpg")
        scene.background.contents = UIImage(named: "art.scnassets/img_skybox.jpg")

        positionBoxs()
        positionFloor(with: matrix)
        positionEndPointSys()

        //print(scene.rootNode.childNodes)
        animateSphere()
        configureCamera()
        sceneView.scene = scene




//        delay(delay: 5) {
//            self.resetInit()
//        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if view.frame.size.width > view.frame.size.height {
            SCNTransaction.animateWithDuration(0.8) {
                cameraYHandle.position.y -= 10
            }
        }
        else  {
            SCNTransaction.animateWithDuration(0.8) {
                self.cameraYHandle.position.y = Float(matrix.count * 2)
            }
        }
    }


    func setUpView() {
        sceneView = SCNView()
        view.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        sceneView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true


        let cameraView = RenderEffectView(effect: UIBlurEffect(style: .light))

        view.addSubview(cameraView)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        cameraView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        cameraView.widthAnchor.constraint(equalToConstant: 44).isActive = true

        cameraView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        cameraView.cornerRadius = 22
        cameraView.clipsToBounds = true

        cameraButton = UIButton(type: .custom)
        cameraView.vibrancyView.contentView.addSubview(cameraButton)
        cameraButton.setImage(UIImage(named: "camera.png"), for: .normal)
        cameraButton.setImage(UIImage(named: "camera-tap.png"), for: .highlighted)
        cameraButton.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        cameraButton.contentMode = .scaleAspectFit
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped(_:)), for: .touchUpInside)

        dismissView = RenderEffectView(effect: UIBlurEffect(style: .light))

        view.addSubview(dismissView)
        dismissView.translatesAutoresizingMaskIntoConstraints = false
        dismissView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        dismissView.widthAnchor.constraint(equalToConstant: 44).isActive = true

        dismissView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        dismissView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        dismissView.cornerRadius = 22
        dismissView.clipsToBounds = true

        let dissButton = UIButton(type: .custom)
        dismissView.vibrancyView.contentView.addSubview(dissButton)
        dissButton.setImage(UIImage(named: "cancel-1.png"), for: .normal)
        dissButton.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        dissButton.contentMode = .scaleAspectFit
        dissButton.addTarget(self, action: #selector(dismissButtonTapped(_:)), for: .touchUpInside)

        dismissView.isHidden = !loadDismissView
    }
    func positionFloor(with matrix: [[Int]]) {

        defaultNodes = SCNNode()
        scene.rootNode.addChildNode(defaultNodes)
        defaultNodes.name = "defaultNodes"
        deQueueNodes = SCNNode()
        scene.rootNode.addChildNode(deQueueNodes)
        deQueueNodes.name = "deQueueNodes"
        queueNodes = SCNNode()
        scene.rootNode.addChildNode(queueNodes)
        queueNodes.name = "queueNodes"

        let defaultFloor = SCNPlane(width: 1, height: 1)
        defaultFloor.cornerRadius = 0.1
        defaultFloor.firstMaterial?.diffuse.contents = defaultColor
        for z in 0 ... matrix.count - 1 {
            for x in 0 ... matrix[0].count - 1 {
                let planeNode = SCNNode(geometry: defaultFloor)
                planeNode.eulerAngles = SCNVector3Make(-.pi/2, 0, 0)
                let zPosition = Float(z - matrix.count / 2)
                let xPosition = Float(x - matrix.count / 2)
                let position = SCNVector3Make(xPosition, 0.02, zPosition)
                let location = Location(z: z, x: x)
                planeNode.position = position
                planeNode.name = location.description
                defaultNodes.addChildNode(planeNode)
            }
        }

        let deQueueFloor = SCNPlane(width: 1, height: 1)
        deQueueFloor.cornerRadius = 0.1
        deQueueFloor.firstMaterial?.diffuse.contents = deQueueColor
        for z in 0 ... matrix.count - 1 {
            for x in 0 ... matrix[0].count - 1 {
                let planeNode = SCNNode(geometry: deQueueFloor)
                planeNode.eulerAngles = SCNVector3Make(-.pi/2, 0, 0)
                let zPosition = Float(z - matrix.count / 2)
                let xPosition = Float(x - matrix.count / 2)
                let position = SCNVector3Make(xPosition, 0.0, zPosition)
                let location = Location(z: z, x: x)
                planeNode.position = position
                planeNode.name = location.description
                planeNode.position = position
                planeNode.opacity = 0
                deQueueNodes.addChildNode(planeNode)
            }
        }

        let queuesFloor = SCNPlane(width: 1, height: 1)
        queuesFloor.cornerRadius = 0.1
        queuesFloor.firstMaterial?.diffuse.contents = enQueueColor
        for z in 0 ... matrix.count - 1 {
            for x in 0 ... matrix[0].count - 1 {
                let planeNode = SCNNode(geometry: queuesFloor)
                planeNode.eulerAngles = SCNVector3Make(-.pi/2, 0, 0)
                let zPosition = Float(z - matrix.count / 2)
                let xPosition = Float(x - matrix.count / 2)
                let position = SCNVector3Make(xPosition, 0.0, zPosition)
                let location = Location(z: z, x: x)
                planeNode.position = position
                planeNode.name = location.description
                planeNode.position = position
                planeNode.opacity = 0
                queueNodes.addChildNode(planeNode)
            }
        }
    }

    func positionBoxs() {
        var position: SCNVector3!
        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
        box.firstMaterial?.lightingModel = .physicallyBased
        box.firstMaterial?.metalness.contents = UIImage(named: "art.scnassets/gold-scuffed-metal.png")
        box.firstMaterial?.normal.contents = UIImage(named: "art.scnassets/gold-scuffed-normal.png")
        box.firstMaterial?.roughness.contents = UIImage(named: "art.scnassets/gold-scuffed-roughness.png")


        let sphere = SCNSphere(radius: 0.5)
        sphere.firstMaterial = box.firstMaterial?.copy() as? SCNMaterial
        sphereNode = SCNNode(geometry: sphere)
        sphereNode.name = "sphere"

        sphereNode.position = SCNVector3Make(Float(entrence.x-matrix.count/2), 0.5, Float(entrence.z-matrix.count/2))
        scene.rootNode.addChildNode(sphereNode)

        let templateNode = SCNNode(geometry: box)

        //box.firstMaterial?.diffuse.contents = UIImage(named: "203843.jpg")
        for z in 0 ... matrix.count-1 {
            for x in 0 ... matrix[0].count-1 {
                let zPosition = Float(z - matrix.count/2)
                let xPosition = Float(x - matrix.count/2)
                if matrix[z][x] == 1 {
                    //                    let boxNode = SCNNode()
                    //                    boxNode.geometry = box
                    //                    position = SCNVector3Make(xPosition, 0.5, zPosition)
                    //                    scene.rootNode.addChildNode(boxNode)
                    //                    boxNode.position = position


                    let boxNode = templateNode.clone()
                    boxNode.name = "boxs"
                    position = SCNVector3Make(xPosition, 0.5, zPosition)
                    boxNode.position = position
                    scene.rootNode.addChildNode(boxNode)
                }
            }

        }


        let tbBox = SCNBox(width: CGFloat(matrix.count+1), height: 1, length: 0.5, chamferRadius: 0.1)
        tbBox.firstMaterial = box.firstMaterial?.copy() as? SCNMaterial
        tbBox.firstMaterial?.diffuse.contents = UIColor.red

        let tbNode = SCNNode(geometry: tbBox)

        let topBox = tbNode.clone()
        topBox.position = SCNVector3Make(0, 0.5, Float(matrix.count/2) + 0.75)
        scene.rootNode.addChildNode(topBox)

        let buttomBox = tbNode.clone()
        buttomBox.position = SCNVector3Make(0, 0.5, -(Float(matrix.count/2) + 0.75))
        scene.rootNode.addChildNode(buttomBox)

        let lrBox = SCNBox(width: 0.5, height: 1, length: CGFloat(matrix.count), chamferRadius: 0.1)
        lrBox.firstMaterial = tbBox.firstMaterial?.copy() as? SCNMaterial

        let lrNode = SCNNode(geometry: lrBox)

        let leftBox = lrNode.clone()
        leftBox.position = SCNVector3Make(-(Float(matrix.count/2) + 0.75), 0.5, 0)
        scene.rootNode.addChildNode(leftBox)

        let rightBox = lrNode.clone()
        rightBox.position = SCNVector3Make(Float(matrix.count/2) + 0.75, 0.5, 0)
        scene.rootNode.addChildNode(rightBox)

    }

    var endPointSys: SCNParticleSystem!

    func positionEndPointSys() {
        endPointSys = SCNParticleSystem(named: "art.scnassets/collect.scnp", inDirectory: nil)!
        let particleNode = SCNNode()
        particleNode.position = SCNVector3Make(Float(endPoint.x-matrix.count/2), 0, Float(endPoint.z-matrix.count/2))
        var particleSystemPosition = particleNode.worldTransform
        particleSystemPosition.m42 += 0.1
        scene.addParticleSystem(endPointSys, transform: particleSystemPosition)
    }

    func convertToPoint(from node: Node) -> SCNVector3 {
        let location = node.location
        return SCNVector3Make(Float(location.x - matrix.count/2), 0.01, Float(location.z - matrix.count/2))
    }

    func animateFloor(with queueNodes: [[Node]], dequeueNodes: [Node], directions: Queue<[Direction]>) {
        var enQueueTimeCount = dequeueNodes.count
        var deQueueTimeCount = dequeueNodes.count


        var i = -1
        var j = -1

        //        print(queueNodes)
        //        print(dequeueNodes)
        //
        enQueuesCoder = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        //enQueuesCoder!.schedule(deadline: .now(), repeating: .seconds(1))
        enQueuesCoder?.schedule(deadline: .now(), repeating: Double(duraction))
        enQueuesCoder!.setEventHandler {
            enQueueTimeCount -= 1
            i += 1
            DispatchQueue.main.async {
                let action = SCNAction.fadeOpacity(to: 0.3, duration: TimeInterval(self.duraction/5))
                let fadeAction = SCNAction.fadeOpacity(to: 1, duration: TimeInterval(self.self.duraction/5))
                let fadeActions = SCNAction.sequence([action, fadeAction])
                let repeatActions = SCNAction.repeat(fadeActions, count: 2)
                let upAction = SCNAction.moveBy(x: 0, y: 0.02, z: 0, duration: TimeInterval(self.duraction/5))
                let actions = SCNAction.group([upAction, repeatActions])
                self.queueNodes.childNode(withName: queueNodes[i].first!.location.description, recursively: true)?.runAction(actions)


                SCNTransaction.animateWithDuration(TimeInterval(self.duraction/5)) {
                    for queueNode in queueNodes[i] {
                        self.queueNodes.childNode(withName: queueNode.location.description, recursively: true)?.position.y = 0.05
                        self.queueNodes.childNode(withName: queueNode.location.description, recursively: true)?.opacity = 1
                    }
                    self.deQueueNodes.childNode(withName: dequeueNodes[i].location.description, recursively: true)?.position.y = 0.03
                    self.deQueueNodes.childNode(withName: dequeueNodes[i].location.description, recursively: true)?.opacity = 0
                }
            }
            if enQueueTimeCount <= 0 { // end
                let locations = self.helper.getCorrectLocation(with: directions.getLast(), entrance: self.entrence)
                DispatchQueue.main.async {
                    delay(delay: 3.0, closure: {
                        for i in 0 ..< locations.count {
                            delay(delay: 1.0 * Double(i) / Double(locations.count), closure: {
                                SCNTransaction.animateWithDuration(TimeInterval(self.self.duraction)) {
                                    self.queueNodes.childNode(withName: locations[i].description, recursively: true)?.position.y = 0.05
                                    self.queueNodes.childNode(withName: locations[i].description, recursively: true)?.opacity = 1
                                    self.deQueueNodes.childNode(withName: locations[i].description, recursively: true)?.position.y = 0.03
                                    self.deQueueNodes.childNode(withName: locations[i].description, recursively: true)?.opacity = 0
                                }
                            })
                        }
                    })
                }
                self.enQueuesCoder!.cancel()
            }
        }

        deQueueCoder = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        deQueueCoder?.schedule(deadline: .now(), repeating: Double(duraction))
        deQueueCoder?.setEventHandler(handler: {
            deQueueTimeCount -= 1
            j += 1
            DispatchQueue.main.async {
                SCNTransaction.animateWithDuration(TimeInterval(self.duraction/2)) {
                    for queueNode in queueNodes[j] {
                        self.queueNodes.childNode(withName: queueNode.location.description, recursively: true)?.position.y = 0.03
                        self.queueNodes.childNode(withName: queueNode.location.description, recursively: true)?.opacity = 1
                    }
                    self.deQueueNodes.childNode(withName: dequeueNodes[j].location.description, recursively: true)?.position.y = 0.05
                    self.deQueueNodes.childNode(withName: dequeueNodes[j].location.description, recursively: true)?.opacity = 1
                }
            }
            if deQueueTimeCount <= 0 {
                DispatchQueue.main.async {

                }
                self.deQueueCoder?.cancel()
            }
        })

        enQueuesCoder!.resume()
        delay(delay: 1.0) {
            self.deQueueCoder?.resume()
        }
    }



    func animateSphere() {
        if entrence.x >= 0 && entrence.x < matrix.count && entrence.z >= 0 && entrence.z < matrix.count && endPoint.x >= 0 && endPoint.x < matrix.count && endPoint.z >= 0 && endPoint.z < matrix.count {
            sphereNode.removeAllActions()
            sphereNode.position = SCNVector3Make(Float(entrence.x-matrix.count/2), 0.5, Float(entrence.z-matrix.count/2))
            let (directions, queueNodes, dequeueNodes, _) = helper.Check(with: matrix, startPoint: entrence, endPoint: endPoint)
            if directions.count > 0 {
                let directionQueue = helper.getAnimationQueue(with: directions)
                let action = helper.getSequenceActions(from: directionQueue, with: duraction)
                delay(delay: Double(duraction), closure: {
                    self.sphereNode.runAction(action, forKey: "sphere")
                })
                animateFloor(with: queueNodes, dequeueNodes: dequeueNodes, directions: directions)
            }
        }
    }
    @objc func cameraButtonTapped(_ sender: UIButton!) {
        //
        if inSky { //in th sky
            guard sceneView.pointOfView!.position.x == 0 && sceneView.pointOfView!.position.y == 0 && sceneView.pointOfView!.position.z == 0 else { return }
            cameraButton.isEnabled = false
            sceneView.allowsCameraControl = false
            cameraButton.isEnabled = false
            self.inSky = false
            let (directions, _, _, flag) = helper.Check(with: matrix, startPoint: entrence, endPoint: endPoint)
            SCNTransaction.animateWithDuration(2.0, timingFunction: nil, completionBlock: {
                if directions.count > 0 {
                    //let directionQueue = self.helper.getAnimationQueue(with: directions)
                    let a = self.helper.getActions(with: directions.getLast())
                    //let action = self.helper.getSequenceActions(from: directionQueue)
                    self.cameraYHandle.runAction(a, forKey: "camera")
                }
                self.cameraButton.isEnabled = true
                self.firstPan = true
            }, animations: {
                cameraYHandle.position = SCNVector3Make(Float(entrence.x-matrix.count/2), 0.5, Float(entrence.z-matrix.count/2))
                cameraYHandle.eulerAngles = SCNVector3Zero
                cameraNode.position = SCNVector3Zero
                cameraNode.eulerAngles = SCNVector3Zero

            })
        } else { // on the floor
            cameraButton.isEnabled = false
            cameraYHandle.removeAction(forKey: "camera")
            inSky = true
            SCNTransaction.animateWithDuration(2.0, timingFunction: nil, completionBlock: {
                self.cameraButton.isEnabled = true
                self.sceneView.allowsCameraControl = true
                self.sceneView.defaultCameraController.interactionMode = .orbitTurntable
                self.sceneView.defaultCameraController.target = SCNVector3Zero
            }, animations: {
                cameraYHandle.position = SCNVector3Make(0, Float(matrix.count * 2), 0)
                cameraYHandle.eulerAngles = SCNVector3Make(Float(-90).degreesToRadians, 0, 0)
                cameraXHandle.position = SCNVector3Zero
                cameraXHandle.eulerAngles = SCNVector3Zero
                cameraNode.position = SCNVector3Zero
                cameraNode.eulerAngles = SCNVector3Zero
            })
        }
    }
    func configureCamera() {
        cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = 100
        cameraNode.camera?.zNear = 0.3
        cameraNode.camera?.motionBlurIntensity = 0.5
        cameraYHandle.position = SCNVector3Make(0, 80, 0)
        cameraYHandle.eulerAngles = SCNVector3Make(Float(-90).degreesToRadians, 0, 0)
        scene.rootNode.addChildNode(cameraYHandle)
        cameraYHandle.name = "camera"
        cameraXHandle.position = SCNVector3Zero
        cameraXHandle.eulerAngles = SCNVector3Zero
        cameraXHandle.name = "camera"
        cameraYHandle.addChildNode(cameraXHandle)

        cameraNode.position = SCNVector3Zero
        cameraNode.eulerAngles = SCNVector3Zero
        cameraXHandle.addChildNode(cameraNode)


        SCNTransaction.animateWithDuration(2.0, timingFunction: nil, completionBlock: {
            self.cameraButton.isEnabled = true
            self.sceneView.allowsCameraControl = true
            self.sceneView.defaultCameraController.interactionMode = .orbitTurntable
            self.sceneView.defaultCameraController.target = SCNVector3Zero
        }, animations: {
            cameraYHandle.position = SCNVector3Make(0, Float(matrix.count * 2), 0)
        })
    }
    // MARK: Managing camera
    func panCamera(_ direction: float2) {
        if inSky {
            return
        }
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
    }
    // MARK: Touch Events
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if panningTouch == nil {
            panningTouch = touches.first
        }
        //        if inSky {
        //            print("begin:")
        //            print(sceneView.pointOfView?.rotation.x.radiansToDegrees ?? "nil")
        //            print(sceneView.pointOfView?.rotation.y.radiansToDegrees ?? "nil")
        //            print(sceneView.pointOfView?.rotation.z.radiansToDegrees ?? "nil")
        //            print(sceneView.pointOfView?.rotation.w.radiansToDegrees ?? "nil")
        //        }
    }
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        if inSky {
        //            print("end:")
        //            print(sceneView.pointOfView?.rotation.x.radiansToDegrees ?? "nil")
        //            print(sceneView.pointOfView?.rotation.y.radiansToDegrees ?? "nil")
        //            print(sceneView.pointOfView?.rotation.z.radiansToDegrees ?? "nil")
        //            print(sceneView.pointOfView?.rotation.w.radiansToDegrees ?? "nil")
        //        }
        if let touch = panningTouch {
            let previousLocationt = float2(touch.previousLocation(in: sceneView))
            let currentLocation = float2(touch.location(in: sceneView))
            let displacement = currentLocation - previousLocationt
            panCamera(displacement)
        }
    }
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        panningTouch = nil
    }
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        panningTouch = nil
    }

    @objc func dismissButtonTapped(_ button: UIButton!) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension BFSGameVC: PlaygroundLiveViewMessageHandler {
   public func receive(_ message: PlaygroundValue) {
       switch message {
       case let .dictionary(dir):
           if case let .integer(i)? = dir["checkQueue"] {
               let direction = Direction(rawValue: i)
               checkQueue.append(direction!)
           } else if case let .array(arr)? = dir["entrence"] {
                guard case let .integer(z) = arr[0], case let .integer(x) = arr[1] else {
                    return
                }
                entrence = Location(z: z, x: x)
            } else if case let .array(arr)? = dir["endPoint"] {
                guard case let .integer(z) = arr[0], case let .integer(x) = arr[1] else {
                    return
                }
                endPoint = Location(z: z, x: x)
            }
        case let .string(text):
            if text == "start" {
                checkQueue = []
            } else if text == "end" {
                resetInit()
            }
       default: break
       }
   }
}
