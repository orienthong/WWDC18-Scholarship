//
//  GameController.swift
//  CameraController
//
//  Created by scauos on 2018/3/27.
//  Copyright © 2018年 scauos. All rights reserved.
//

import UIKit
import SceneKit
import PlaygroundSupport

public class GameController: UIViewController, PlaygroundLiveViewSafeAreaContainer {
    var panningTouch: UITouch? = nil
    var gameScene: GameScene!
    var firstPan = true
    var sceneView: SCNView!

    var resetButton: UIButton!
    var cameraView: RenderEffectView! //change Camera location

    var timmingLabel: UILabel!
    var timmingView: RenderEffectView!

    var upButton = UIButton(type: .custom)
    var downButton = UIButton(type: .custom)
    var leftButton = UIButton(type: .custom)
    var rightButton = UIButton(type: .custom)

    var upView = RenderEffectView(effect: UIBlurEffect(style: .light))
    var downView = RenderEffectView(effect: UIBlurEffect(style: .light))
    var leftView = RenderEffectView(effect: UIBlurEffect(style: .light))
    var rightView = RenderEffectView(effect: UIBlurEffect(style: .light))

    var coder: DispatchSourceTimer? = nil

    private var cameraPositionWhileFailed: SCNVector3!
    private var cameraEulerAnglesWileFailed: SCNVector3!

    private var flag = true

    public var configurator: Configurator? {
        get {
            return gameScene.configurator
        }
        set(newValue) {
            gameScene.configurator = newValue
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        gameScene = GameScene()
        setUpView()
        setUpTimmingView()
        setUpButton()
        sceneView.scene = gameScene
    }
    public override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        upView.removeConstraints(upView.constraints)
        upView.removeConstraints(upView.constraints)
        leftView.removeConstraints(leftView.constraints)
        rightView.removeConstraints(rightView.constraints)

        layoutButtons()
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        upView.removeConstraints(upView.constraints)
        upView.removeConstraints(upView.constraints)
        leftView.removeConstraints(leftView.constraints)
        rightView.removeConstraints(rightView.constraints)
        layoutButtons()


    }
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if gameScene.helper.state == .tapToBegin {
            if view.frame.size.width > view.frame.size.height {
                SCNTransaction.animateWithDuration(0.8) {
                    gameScene.cameraYHandle.position.y -= 5
                }
            }
            else  {
                SCNTransaction.animateWithDuration(0.8) {
                    gameScene.cameraYHandle.position.y = configurator!.welcomeCameraHeight
                }
            }
        }
    }

    func setUpButton() {
        var controlButtons = [upButton, downButton, leftButton, rightButton]
        let controlViews = [upView, downView, leftView, rightView]
        let imageNames = ["up-circle-o.png", "down-circle-o.png", "left-circle-o.png", "right-circle-o.png"]
        let imageNamesTap = ["up-circle.png", "down-circle.png", "left-circle.png", "right-circle.png"]

        for i in 0 ... controlButtons.count-1 {
            view.addSubview(controlViews[i])
            controlButtons[i].setImage(UIImage(named: imageNames[i]), for: .normal)
            controlButtons[i].setImage(UIImage(named: imageNamesTap[i]), for: .highlighted)
            controlButtons[i].contentMode = .scaleAspectFit
            controlViews[i].translatesAutoresizingMaskIntoConstraints  = false
            controlViews[i].alpha = 0.0
            controlViews[i].vibrancyView.contentView.addSubview(controlButtons[i])
            controlButtons[i].autoresizingMask = [.flexibleHeight, .flexibleWidth]
            controlViews[i].cornerRadius = 30
            controlViews[i].clipsToBounds = true

        }
        upButton.addTarget(self, action: #selector(upButtonTapped(_:)), for: .touchUpInside)
        downButton.addTarget(self, action: #selector(downButtonTapped(_:)), for: .touchUpInside)
        leftButton.addTarget(self, action: #selector(leftButtonTapped(_:)), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(rightButtonTapped(_:)), for: .touchUpInside)
    }
    func layoutButtons() {

        let controlViews = [upView, downView, leftView, rightView]
        let size: CGFloat = 60.0

        for controlView in controlViews {
            controlView.heightAnchor.constraint(equalToConstant: size).isActive = true
            controlView.widthAnchor.constraint(equalToConstant: size).isActive = true
        }

        leftView.leadingAnchor.constraint(equalTo: liveViewSafeAreaGuide.leadingAnchor, constant: 16).isActive = true
        leftView.bottomAnchor.constraint(equalTo: liveViewSafeAreaGuide.bottomAnchor, constant: -80).isActive = true

        downView.topAnchor.constraint(equalTo: leftView.bottomAnchor, constant: 4).isActive = true
        downView.leadingAnchor.constraint(equalTo: leftView.trailingAnchor, constant: 4).isActive = true

        rightView.leadingAnchor.constraint(equalTo: downView.trailingAnchor, constant: 4).isActive = true
        rightView.centerYAnchor.constraint(equalTo: leftView.centerYAnchor).isActive = true

        upView.bottomAnchor.constraint(equalTo: leftView.topAnchor, constant: -4).isActive = true
        upView.centerXAnchor.constraint(equalTo: downView.centerXAnchor).isActive = true

    }


    func setUpView() {
        sceneView = SCNView()
        view.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        sceneView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true


        let visualView = RenderEffectView(effect: UIBlurEffect(style: .light))


        view.addSubview(visualView)
        visualView.translatesAutoresizingMaskIntoConstraints = false
        visualView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        visualView.widthAnchor.constraint(equalToConstant: 50).isActive = true

        visualView.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: 16).isActive = true
        visualView.trailingAnchor.constraint(equalTo: liveViewSafeAreaGuide.trailingAnchor, constant: -16).isActive = true
        visualView.cornerRadius = 25
        visualView.clipsToBounds = true


        resetButton = UIButton(type: .custom)
        visualView.vibrancyView.contentView.addSubview(resetButton)
        resetButton.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        resetButton.setImage(UIImage(named: "refresh.png"), for: .normal)
        resetButton.setImage(UIImage(named: "refresh-tap.png"), for: .highlighted)
        resetButton.addTarget(self, action: #selector(resetButtonTapped(_:)), for: .touchUpInside)

        cameraView = RenderEffectView(effect: UIBlurEffect(style: .light))

        view.addSubview(cameraView)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        cameraView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        cameraView.widthAnchor.constraint(equalToConstant: 50).isActive = true

        cameraView.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: 16).isActive = true
        cameraView.leadingAnchor.constraint(equalTo: liveViewSafeAreaGuide.leadingAnchor, constant: 16).isActive = true
        cameraView.cornerRadius = 25
        cameraView.clipsToBounds = true

        let cameraButton = UIButton(type: .custom)
        cameraView.vibrancyView.contentView.addSubview(cameraButton)
        cameraButton.setImage(UIImage(named: "camera.png"), for: .normal)
        cameraButton.setImage(UIImage(named: "camera-tap.png"), for: .highlighted)
        cameraButton.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        cameraButton.contentMode = .scaleAspectFit
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped(_:)), for: .touchUpInside)

        cameraView.alpha = 0.0
    }



    // MARK: BUTTON
    @objc func resetButtonTapped(_ button: UIButton!) {
      gameScene.cameraYHandle.removeAction(forKey: "camera")
      timmingView.alpha = 0
      UIView.animate(withDuration: 0.8, animations: {
          self.cameraView.alpha = 0.0
      })
      switch gameScene.helper.state {
      case .tapToBegin: break
      case .timming: return
      case .began:
          gameScene.animationQueue = Queue<Direction>()
          button.isEnabled = false
          let animator = UIViewPropertyAnimator(duration: 0.8, curve: .easeOut, animations: {
                self.upView.alpha = 0.0
                self.downView.alpha = 0.0
                self.leftView.alpha = 0.0
                self.rightView.alpha = 0.0
            })
            animator.startAnimation()
          delay(delay: 0.5, closure: {
              button.isEnabled = true
          })
          if coder != nil {
                coder!.cancel()
                coder = nil
                UIView.animate(withDuration: 0.5, animations: {
                    self.timmingView.alpha = 0
                    self.timmingView.vibrancyView.contentView.backgroundColor = nil
                })
            }
          case .gameWin:
                gameScene.animationQueue = Queue<Direction>()
            case .gameLose:
                gameScene.animationQueue = Queue<Direction>()
                SCNTransaction.animateWithDuration(0.8) {
                    self.gameScene.camera.vignettingPower = 0
                    self.gameScene.camera.saturation = 1.0
                    self.gameScene.camera.wantsDepthOfField = false
                }
                button.isEnabled = false
                delay(delay: 0.5, closure: {
                    button.isEnabled = true
                })
      }
      firstPan = true
      panningTouch = nil
      gameScene.resetGame()
      flag = true
    }

    // MARK: Timming
    func setUpTimmingView() {
            timmingView = RenderEffectView(effect: UIBlurEffect(style: .light))
            view.addSubview(timmingView)
            timmingView.translatesAutoresizingMaskIntoConstraints = false
            timmingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            timmingView.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: 16).isActive = true
            timmingView.heightAnchor.constraint(equalToConstant: 60).isActive = true
            timmingView.widthAnchor.constraint(equalToConstant: 60).isActive = true
            timmingView.layer.cornerRadius = 30
            timmingView.clipsToBounds = true
            timmingLabel = UILabel()
            timmingLabel.text = ""
            timmingLabel.textColor = .green
            timmingLabel.textAlignment = .center
            timmingLabel.adjustsFontSizeToFitWidth = true
            timmingView.cornerRadius = 30
            timmingView.vibrancyView.contentView.addSubview(timmingLabel)
            timmingView.alpha = 0.0
            timmingLabel.autoresizingMask = [.flexibleHeight, .flexibleWidth]

    }

    func gameTimming(with time: Int) {

        UIView.animate(withDuration: 0.5, animations: {
            self.timmingView.alpha = 1.0
            self.timmingView.vibrancyView.contentView.backgroundColor = .red
        })
        var timeCount = time + 1
        coder = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        coder!.schedule(deadline: .now(), repeating: .seconds(1))
        coder!.setEventHandler {
            timeCount -= 1
            if timeCount <= 0 { // game end
                if self.gameScene.helper.state == .began { // failed
                  self.gameScene.helper.state = .gameLose
                  self.cameraPositionWhileFailed = self.gameScene.cameraYHandle.position
                  self.cameraEulerAnglesWileFailed = self.gameScene.cameraYHandle.eulerAngles
                    DispatchQueue.main.async {
                        self.gameOver()
                        self.showErrorMessage()
                        UIView.animate(withDuration: 0.8, animations: {
                            self.timmingView.vibrancyView.contentView.backgroundColor = nil
                            self.upView.alpha = 0
                            self.downView.alpha = 0
                            self.leftView.alpha = 0
                            self.rightView.alpha = 0
                            self.cameraView.alpha = 1
                        })
                        SCNTransaction.animateWithDuration(0.8) {
                            self.gameScene.camera.vignettingPower = 1.0
                            self.gameScene.camera.wantsDepthOfField = true
                            self.gameScene.camera.focusDistance = 0.1
                            self.gameScene.camera.fStop = 5.6
                            self.gameScene.camera.saturation = 0
                        }
                    }
                }
                self.coder!.cancel()
                self.coder = nil
            }
            DispatchQueue.main.async { //do each second
                self.timmingLabel.text = "\(timeCount)"
            }
        }
        coder!.resume()
    }


    func startTimming(with time: Int) {
        gameScene.helper.state = .timming
        UIView.animate(withDuration: 0.5, animations: {
            self.timmingView.alpha = 1.0
        })
        SCNTransaction.animateWithDuration(0.8) {
            gameScene.cameraYHandle.position = SCNVector3Make(0, configurator!.cameraHeight, 0)
        }
        var timeCount = time + 1
        let codeTimer = DispatchSource.makeTimerSource(queue:      DispatchQueue.global())
        codeTimer.schedule(deadline: .now(), repeating: .seconds(1))
        codeTimer.setEventHandler(handler: {
            timeCount = timeCount - 1
            if timeCount <= 0 {
                self.gameScene.helper.state = .began
                self.gameScene.cameraDircetion = .forward

                DispatchQueue.main.async {

                    if let gameTimming = self.configurator!.gameTimming { //game was timming
                        //NSLog("timming")
                        self.gameTimming(with: gameTimming)
                    }
                    self.resetButton.isEnabled = true
                    UIView.animate(withDuration: 0.5, animations: {
                        self.timmingView.alpha = 1
                    })
                    SCNTransaction.animateWithDuration(0.5, timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut), completionBlock: {
                        self.gameScene.helper.state = .began
                        UIView.animate(withDuration: 0.8, animations: {
                            self.upView.alpha = 1.0
                            self.downView.alpha = 1.0
                            self.leftView.alpha = 1.0
                            self.rightView.alpha = 1.0
                            self.gameScene.audioNode.runAction(SCNAction.playAudio(self.gameScene.audioSource, waitForCompletion: false))
                        })
                    }, animations: {
                        self.gameScene.sphereNode.isHidden = true
                        self.gameScene.cameraYHandle.position = SCNVector3Make(Float(self.configurator!.Entrance.x - self.configurator!.Matrix.count/2), 0.5, Float(self.configurator!.Entrance.z - self.configurator!.Matrix.count/2))
                        self.gameScene.cameraYHandle.eulerAngles = SCNVector3Zero
                    })
                }
                codeTimer.cancel()
            }
            DispatchQueue.main.async {
                self.timmingLabel.text = "\(timeCount)"
            }
        })
        // 启动时间源
        codeTimer.resume()


    }

    // MARK: GameControl
    func presentWinningScene() {
        gameOver()
        showSuccessMessage()
        UIView.animate(withDuration: 0.8) {
            self.upView.alpha = 0.0
            self.rightView.alpha = 0.0
            self.leftView.alpha = 0.0
            self.downView.alpha = 0.0
            self.cameraView.alpha = 1.0
        }
        if configurator!.gameTimming != nil {
            UIView.animate(withDuration: 0.5, animations: {
                self.timmingView.alpha = 0
                self.timmingView.vibrancyView.contentView.backgroundColor = nil
            })
            if coder != nil {
                coder!.cancel()
                coder = nil
            }
        }
    }

    @objc func upButtonTapped(_ button: UIButton!) {
        switch gameScene.cameraDircetion {
        case .forward:
            gameScene.moveSphere(with: Direction.forward)
        case .left:
            gameScene.moveSphere(with: Direction.left)
        case .backward:
            gameScene.moveSphere(with: Direction.backward)
        case .right:
            gameScene.moveSphere(with: Direction.right)
        }
        if gameScene.currentLocation == gameScene.configurator!.EndPoint {
            presentWinningScene()
        }
    }

    @objc func downButtonTapped(_ button: UIButton!) {
        switch gameScene.cameraDircetion {
        case .forward:
            gameScene.moveSphere(with: Direction.backward)
        case .left:
            gameScene.moveSphere(with: Direction.right)
        case .backward:
            gameScene.moveSphere(with: Direction.forward)
        case .right:
            gameScene.moveSphere(with: Direction.left)
        }
        if gameScene.currentLocation == gameScene.configurator!.EndPoint {
            presentWinningScene()
        }
    }

    @objc func leftButtonTapped(_ button: UIButton!) {
        switch gameScene.cameraDircetion {
        case .forward:
            gameScene.moveSphere(with: Direction.left)
        case .left:
            gameScene.moveSphere(with: Direction.backward)
        case .backward:
            gameScene.moveSphere(with: Direction.right)
        case .right:
            gameScene.moveSphere(with: Direction.forward)
        }
        if gameScene.currentLocation == gameScene.configurator!.EndPoint {
            presentWinningScene()
        }
    }

    @objc func rightButtonTapped(_ button: UIButton!) {
        switch gameScene.cameraDircetion {
        case .forward:
            gameScene.moveSphere(with: Direction.right)
        case .left:
            gameScene.moveSphere(with: Direction.forward)
        case .backward:
            gameScene.moveSphere(with: Direction.left)
        case .right:
            gameScene.moveSphere(with: Direction.backward)
        }
        if gameScene.currentLocation == gameScene.configurator!.EndPoint {
            presentWinningScene()
        }
    }

    @objc func cameraButtonTapped(_ button: UIButton!) {
        if gameScene.helper.state == .gameWin {
            button.isEnabled = false
            SCNTransaction.animateWithDuration(1.0, timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut), completionBlock: {
                if let actions = self.gameScene.sphereNode.action(forKey: "sphere") {
                    self.gameScene.cameraYHandle.runAction(SCNAction.repeatForever(actions), forKey: "camera")
                }
                self.gameScene.helper.state = .began
                self.firstPan = true
                self.panningTouch = nil
                button.isEnabled = true
            }) {
                gameScene.cameraYHandle.eulerAngles = SCNVector3Zero
                gameScene.cameraYHandle.position = SCNVector3Make(Float(configurator!.Entrance.x-configurator!.Matrix.count/2), 0.5, Float(configurator!.Entrance.z - configurator!.Matrix.count/2))
            }
        }
        else if gameScene.helper.state == .gameLose {
            guard gameScene.animationQueue.count > 0 else { return }
            button.isEnabled = false
            if flag { // on the floor
                gameScene.sphereNode.removeAction(forKey: "sphere")
                gameScene.sphereNode.isHidden = false
                let actions = gameScene.helper.getActions(with: gameScene.animationQueue.getAll())

                SCNTransaction.animateWithDuration(1.0, timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut), completionBlock: {
                    self.gameScene.sphereNode.runAction(SCNAction.repeatForever(actions), forKey: "sphere")
                    button.isEnabled = true
                    self.flag = !self.flag
                }) {
                    self.gameScene.camera.vignettingPower = 0
                    self.gameScene.camera.saturation = 1.0
                    self.gameScene.camera.wantsDepthOfField = false

                    gameScene.cameraYHandle.position = SCNVector3Make(0, configurator!.cameraHeight, 0)
                    gameScene.cameraYHandle.eulerAngles = SCNVector3Make(Float(-90).degreesToRadians, 0, 0)
                    gameScene.cameraXHandle.position = SCNVector3Zero
                    gameScene.cameraXHandle.eulerAngles = SCNVector3Zero
                    gameScene.cameraNode.position = SCNVector3Zero
                    gameScene.cameraNode.eulerAngles = SCNVector3Zero

                }
            } else { //in the sky
                let zPosition = Float(configurator!.Entrance.z - configurator!.Matrix.count/2)
                let xPosition = Float(configurator!.Entrance.x - configurator!.Matrix.count/2)
                gameScene.sphereNode.removeAction(forKey: "sphere")
                gameScene.sphereNode.position = SCNVector3Make(xPosition, 0.5, zPosition)
                gameScene.sphereNode.isHidden = true

                SCNTransaction.animateWithDuration(1.0, completionBlock: {
                    button.isEnabled = true
                    self.flag = !self.flag
                }) {
                    self.gameScene.camera.vignettingPower = 1.0
                    self.gameScene.camera.wantsDepthOfField = true
                    self.gameScene.camera.focusDistance = 0.1
                    self.gameScene.camera.fStop = 5.6
                    self.gameScene.camera.saturation = 0
                    self.gameScene.cameraYHandle.position = cameraPositionWhileFailed
                    self.gameScene.cameraYHandle.eulerAngles = cameraEulerAnglesWileFailed
                }

            }
        }
        else {
            button.isEnabled = false
            self.gameScene.helper.state = .gameWin
            gameScene.cameraYHandle.removeAction(forKey: "camera")
            SCNTransaction.animateWithDuration(2.0, timingFunction: nil, completionBlock: {
                button.isEnabled = true
            }, animations: {
                gameScene.cameraYHandle.position = SCNVector3Make(0, configurator!.cameraHeight, 0)
                gameScene.cameraYHandle.eulerAngles = SCNVector3Make(Float(-90).degreesToRadians, 0, 0)
                gameScene.cameraXHandle.position = SCNVector3Zero
                gameScene.cameraXHandle.eulerAngles = SCNVector3Zero
                gameScene.cameraNode.position = SCNVector3Zero
                gameScene.cameraNode.eulerAngles = SCNVector3Zero
            })
        }
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesBegan(touches, with: event)
      print(configurator!.ifUserTouch)
      print("super touch began")
      if configurator!.ifUserTouch {
          switch gameScene.helper.state {
          case .tapToBegin:
              NSLog("tapToBegin")
              if configurator == nil {
                  NSLog("nil configurator")
              }
              gameScene.gameStart()
              resetButton.isEnabled = false
              startTimming(with: configurator!.time!)
          case .timming:
              break
          case .began:
              if panningTouch == nil {
                  panningTouch = touches.first
              }
          case .gameWin:
              panningTouch = nil
              break
          case .gameLose:
              panningTouch = nil
              break
          }
      }
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesMoved(touches, with: event)
      if configurator!.ifUserTouch {
          if let touch = panningTouch {
              let previousLocationt = float2(touch.previousLocation(in: sceneView))
              let currentLocation = float2(touch.location(in: sceneView))
              let displacement = currentLocation - previousLocationt
              gameScene.panCamera(displacement, firstPan: &firstPan)
          }
      }
    }
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        panningTouch = nil
    }
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        panningTouch = nil
    }
    func gameOver() {

    }
    func showSuccessMessage() {

    }

    func showErrorMessage() { }


}
