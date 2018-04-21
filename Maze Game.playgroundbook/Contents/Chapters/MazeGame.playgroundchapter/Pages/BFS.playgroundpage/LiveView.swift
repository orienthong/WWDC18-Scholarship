import PlaygroundSupport
let viewController = BFSGameVC()
viewController.checkQueue = [.forward, .right, .left, .backward]
PlaygroundPage.current.liveView = viewController
