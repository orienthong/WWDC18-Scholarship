import UIKit
import SceneKit
import PlaygroundSupport

public class SecondGameVC: GameController {

    override public func viewDidLoad() {

        super.viewDidLoad()

    }
    override func showSuccessMessage() {
        super.showSuccessMessage()
        let Dict: PlaygroundValue = .dictionary(["success": PlaygroundValue.boolean(true)])
        send(Dict)
    }
    override func showErrorMessage() {
      super.showErrorMessage()
      let Dict: PlaygroundValue = .dictionary(["success": PlaygroundValue.boolean(false)])
      send(Dict)
    }
}

extension SecondGameVC: PlaygroundLiveViewMessageHandler {
    public func receive(_ message: PlaygroundValue) {
    }
}
