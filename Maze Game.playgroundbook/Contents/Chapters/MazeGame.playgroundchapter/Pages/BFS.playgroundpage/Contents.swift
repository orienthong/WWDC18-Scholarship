/*:
## Welcome to the AI🤖 page

Computer is powerful👍, it helps people solve many problems efficiently. In our maze game, computer can helps us find our way out quickly.

**In this page**, you will figure how algorithm solve the maze.

**Game Design**

|- - - - - - - - - - - -> +x

|0, 0, 0, 1, 0, 0, 1 ...

|0, 1, 0, 1, 0 ...

|0, 1, 0 ...

V

+z

**Number '0' represent a road and '1' represents a wall**

# Breadth-First Search (BFS)

 Every time the ball 🏐 goes one step, it can judge whether can go up, down, left or right. If it can, join the next location to queue, if it can't get through, then dequeue and go back.

**In this page**, you can enter different entrence and endPoint. The Playground will help you find the way out. I hope you enjoy.

**Tips** You are free to control the maze, touch the screen and move!😜


*/

//#-hidden-code
import PlaygroundSupport
let page = PlaygroundPage.current
page.needsIndefiniteExecution = true
let proxy = page.liveView as! PlaygroundRemoteLiveViewProxy

var checkQueue = [Direction]()
var entrance: Location!
var endPoint: Location!
//#-end-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(identifier, show, entrance, endPoint, Location)
//#-editable-code
entrance = Location(z: 14, x: 0)
endPoint = Location(z: 0, x: 12)
// Direction  .forward:  ⬆️
//            .backward: ⬇️
//            .left:     ⬅️
//            .right:    ➡️
checkQueue = [.forward,
              .left,
              .backward,
              .right]
//#-end-editable-code
//#-hidden-code
proxy.send(PlaygroundValue.string("start"))
for i in 0 ... checkQueue.count-1 {
    proxy.send(PlaygroundValue.dictionary(["checkQueue": .integer(checkQueue[i].rawValue)]))
}
proxy.send(PlaygroundValue.dictionary(["entrence" : .array([PlaygroundValue.integer(entrance.z), PlaygroundValue.integer(entrance.x)])]))
proxy.send(PlaygroundValue.dictionary(["endPoint" : .array([PlaygroundValue.integer(endPoint.z), PlaygroundValue.integer(endPoint.x)])]))
proxy.send(PlaygroundValue.string("start"))
proxy.send(PlaygroundValue.string("end"))
//#-end-hidden-code
