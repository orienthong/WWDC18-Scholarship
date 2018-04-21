//
//  FirstGameController.swift
//  CameraController
//
//  Created by scauos on 2018/3/20.
//  Copyright © 2018年 scauos. All rights reserved.
//

import UIKit
import SceneKit
import PlaygroundSupport

public class FirstGameController: GameController {

    override public func viewDidLoad() {
        super.viewDidLoad()
        //DEBUG
        let configurator = Configurator()
        configurator.gameTimming = 20
        gameScene.configurator = configurator
//        delay(delay: 5.0) {
//            self.gameScene.resetGame()
//        }
//        delay(delay: 10.0) {
//            self.gameScene.gameStart()
//        }
        //END DEBUG
    }
    override func showSuccessMessage() {
        super.showSuccessMessage()
        let Dict: PlaygroundValue = .dictionary(["success": PlaygroundValue.boolean(true)])
        send(Dict)
        NSLog("loggggging")
    }

}
extension FirstGameController: PlaygroundLiveViewMessageHandler {
    public func receive(_ message: PlaygroundValue) {

    }
}
