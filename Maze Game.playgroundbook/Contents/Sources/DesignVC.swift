//
//  DesignVC.swift
//  CameraController
//
//  Created by scauos on 2018/3/31.
//  Copyright © 2018年 scauos. All rights reserved.
//

import UIKit
import SpriteKit
import PlaygroundSupport

protocol DesignVCDelegate: class {
    func didDesign(with copy: Configurator)
}

@objc(DesignVC)
class DesignVC: UIViewController {

    //var spriteScene = SpriteScene()
    let scene = SpriteScene()
    let helper = GameHelper()

    weak var delegate: DesignVCDelegate?

    @IBOutlet weak var spriteView: SKView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var cancelView: UIVisualEffectView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var safeArea: UIView!


    @IBAction func doneButtonTapped(_ sender: UIButton) {
        if !scene.hadEndPoint || !scene.hadEntrence {
            let alertController = UIAlertController(title: "Opps! 😲", message: "You did not sign the entrence or endpoint, please check again☺️", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK 😎", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            let (_, _, _, flag) = helper.Check(with: scene.matrix, startPoint: scene.entrence, endPoint: scene.endPoint)
            if !flag {
                let alertController = UIAlertController(title: "Opps! 🤔", message: "AI🤖 can not find the way out, can you?", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "I can😎", style: .cancel, handler: { _ in
                    self.delegate?.didDesign(with: self.scene.configurator!)
                    self.dismiss(animated: true, completion: nil)
                })
                alertController.addAction(okAction)
                let noAction = UIAlertAction(title: "OK 😶", style: .default, handler: nil)
                alertController.addAction(noAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                delegate?.didDesign(with: scene.configurator!)
                dismiss(animated: true, completion: nil)
            }
        }
    }

    var configurator: Configurator!


    public override func viewDidLoad() {
        super.viewDidLoad()

        safeArea.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: 20).isActive = true
        safeArea.bottomAnchor.constraint(equalTo: liveViewSafeAreaGuide.bottomAnchor).isActive = true


        configurator = Configurator()
        scene.scaleMode = .resizeFill

        scene.configurator = configurator


        spriteView.preferredFramesPerSecond = 60
        spriteView.presentScene(scene)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    @IBAction func entrenceTapped(_ sender: UIButton) {

        scene.state = .entrence
        print(scene.state)
    }

    @IBAction func endPointTapped(_ sender: Any) {
        scene.state = .endpoint
    }
    @IBAction func roadTapped(_ sender: UIButton) {
        scene.state = .road
    }
    @IBAction func wallTapped(_ sender: UIButton) {
        scene.state = .wall
    }
}

extension DesignVC {
    class func loadFromStoryboard() -> UIViewController? {
        let storyboard = UIStoryboard.init(name: "DesignVC", bundle: nil)
        return storyboard.instantiateInitialViewController()
    }
}
extension DesignVC: PlaygroundLiveViewSafeAreaContainer {}
