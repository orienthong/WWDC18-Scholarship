/*:
 ## Hello, Welcome

 **Welcome amazing Maze Game.**



 **Tips:** Tap to begin! Try your best to remember the maze and figure out the way from the entrance to the destination.

 After you are navigated, move to the destination with your fastest speed or you will lose.

 When you are in the maze, you can sliding the screen to control the direction! **Good Luck**👍👍👍
 */
//#-hidden-code
import UIKit
import PlaygroundSupport
let page = PlaygroundPage.current
page.needsIndefiniteExecution = true
let proxy = page.liveView as! PlaygroundRemoteLiveViewProxy


class MyClassThatListens: PlaygroundRemoteLiveViewProxyDelegate {
    public func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) {
    }
    func remoteLiveViewProxy(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy, received message: PlaygroundValue) {
        NSLog("remote")
        if case let .dictionary(dic) = message {
            guard case let .boolean(success)? = dic["success"] else {
                return
            }

            if Bool(success) { //in good mood then success
                NSLog("success")
                page.assessmentStatus = .pass(message: "## Congratulation👏👏🏻👏🏽 \n\nYou have overcome this maze successfully. It's pretty easy right? Let's move to next page. It will not be easy. \n\n[**Next Page**](@next)")
            }
        }
    }
}

let listener = MyClassThatListens()
proxy.delegate = listener

//#-end-hidden-code
//#-code-completion(everything, hide)
