/*:
 # Now, Design Your Maze

 **Tips-1:** Tap to Design button to the top and draw your maze. Have Fun!😊

 **Tips-2:** You can change the game's default value to manager the game.

 */


//#-hidden-code
import UIKit
import PlaygroundSupport
let viewController = FinalGameVC()
PlaygroundPage.current.liveView = viewController
let configurator = Configurator()
//#-end-hidden-code
//#-editable-code
//#-code-completion(everything, hide)
configurator.gameTimming = 20
configurator.time = 15
configurator.cellCount = 13
configurator.boxColors = [#colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1) , #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1), #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1), #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]
//#-end-editable-code
viewController.configurator = configurator
//#-end-hidden-code
//#-code-completion(everything, hide)
