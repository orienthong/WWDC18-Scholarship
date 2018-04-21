//
//  FinalGameVC.swift
//  CameraController
//
//  Created by scauos on 2018/3/31.
//  Copyright © 2018年 scauos. All rights reserved.
//

import UIKit
import SceneKit


public class FinalGameVC: GameController {
    var designButton: UIButton!
    var aiView: RenderEffectView!


    override public func viewDidLoad() {
        super.viewDidLoad()
        let configurator = Configurator()
        configurator.ifUserTouch = false
        gameScene.configurator = configurator


    }

    override func setUpView() {
        super.setUpView()

        designButton = UIButton(type: .custom)
        designButton.setImage(UIImage(named: "design.png"), for: .normal)
        designButton.addTarget(self, action: #selector(designButtonTapped(_:)), for: .touchUpInside)

        let visualView = RenderEffectView(effect: UIBlurEffect(style: .light))
        visualView.vibrancyView.contentView.addSubview(designButton)
        designButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        designButton.contentMode = .scaleAspectFit

        view.addSubview(visualView)
        visualView.translatesAutoresizingMaskIntoConstraints = false
        visualView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        visualView.heightAnchor.constraint(equalTo: visualView.widthAnchor).isActive = true
        visualView.trailingAnchor.constraint(equalTo: resetButton.leadingAnchor, constant: -10).isActive = true
        visualView.topAnchor.constraint(equalTo: resetButton.topAnchor).isActive = true
        visualView.cornerRadius = 22
        visualView.clipsToBounds = true

        let aiButton = UIButton(type: .custom)
        aiButton.setImage(UIImage(named: "robot.png"), for: .normal)
        aiButton.addTarget(self, action: #selector(aiButtonTapped(_:)), for: .touchUpInside)

        aiView = RenderEffectView(effect: UIBlurEffect(style: .light))
        aiView.vibrancyView.contentView.addSubview(aiButton)
        aiButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        aiButton.contentMode = .scaleAspectFit

        view.addSubview(aiView)
        aiView.translatesAutoresizingMaskIntoConstraints = false
        aiView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        aiView.heightAnchor.constraint(equalTo: aiView.widthAnchor).isActive = true
        aiView.trailingAnchor.constraint(equalTo: visualView.leadingAnchor, constant: -10).isActive = true
        aiView.topAnchor.constraint(equalTo: visualView.topAnchor).isActive = true
        aiView.cornerRadius = 22
        aiView.clipsToBounds = true

        aiView.isHidden = true

    }

    @objc func designButtonTapped(_ button: UIButton!) {
        configurator!.ifUserTouch = false
        if gameScene.helper.state != .tapToBegin { return }
        let designVC = DesignVC.loadFromStoryboard() as? DesignVC
        designVC?.delegate = self
        self.present(designVC!, animated: true, completion: nil)
    }

    @objc func aiButtonTapped(_ button: UIButton!) {
        let bfsGameVC = BFSGameVC()
        bfsGameVC.checkQueue = configurator!.checkQueue
        bfsGameVC.matrix = configurator!.Matrix
        bfsGameVC.entrence = configurator!.Entrance
        bfsGameVC.endPoint = configurator!.EndPoint
        bfsGameVC.loadDismissView = true
        bfsGameVC.modalTransitionStyle = .flipHorizontal
        self.present(bfsGameVC, animated: true, completion: nil)

    }

    override func resetButtonTapped(_ button: UIButton!) {
        super.resetButtonTapped(button)
        aiView.isHidden = true
        designButton.isEnabled = true
        configurator!.ifUserTouch = true
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if gameScene.helper.state == .tapToBegin {
            designButton.isEnabled = true
        } else {
            designButton.isEnabled = false
        }
    }

    override func gameOver() {
        aiView.isHidden = false
    }
}

extension FinalGameVC: DesignVCDelegate {
    func didDesign(with copy: Configurator) {
        configurator!.Matrix = copy.Matrix
        configurator!.cameraHeight = Float(copy.Matrix.count * 2)
        configurator!.Entrance = copy.Entrance
        configurator!.EndPoint = copy.EndPoint
        configurator!.ifUserTouch = true
        gameScene.configurator = configurator
    }
}
