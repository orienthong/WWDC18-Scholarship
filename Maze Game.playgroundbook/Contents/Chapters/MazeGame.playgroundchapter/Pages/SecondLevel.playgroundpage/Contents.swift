/*:
 ## Welcome the second page

 Yep😁, I design one more complex maze for you to challenge.

 **Run Code** and try your best to win the game.

 **By the way**, you can change the game default value to custom your game.
 */

//#-hidden-code

import UIKit
import PlaygroundSupport

let page = PlaygroundPage.current
let viewController = SecondGameVC()
page.liveView = viewController


let configurator = Configurator()
configurator.Matrix = [[0,0,0,1,0,0,1,0,0,0,0,1,0,1,0],
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

configurator.Entrance = Location(z: 14, x: 0)
configurator.EndPoint = Location(z: 0, x: 12)
configurator.cameraHeight = 30

//#-end-hidden-code
//#-editable-code
//#-code-completion(everything, hide)

// the time you take the challenge
configurator.gameTimming = 30

// the random color for the boxs (walls)
configurator.boxColors = [#colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1) , #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1), #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1), #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]

// the time you use to remember the maze
configurator.time = 15
//#-end-editable-code

//#-hidden-code
viewController.configurator = configurator
//#-end-hidden-code
