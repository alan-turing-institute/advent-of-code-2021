import scala.io.Source


def loadData(path: String = "input.txt"): Iterator[(String, Int)] =
    val file = Source.fromFile(path)
    file.getLines
        .map(_.split(" "))
        .map(values => (values(0), values(1).toInt))


/** Convert up/down/forward message into a tuple of (hoirzontal position, depth, aim).
 *  Pos stores current position & aim, instr the new insttruction.
 */
def updatePosition(pos: (Int, Int, Int), instr: (String, Int)) =
    val (hor, dep, aim) = pos
    val (command, delta) = instr
    command match
        case "up" => (hor, dep, aim - delta) // decrease aim
        case "down" => (hor, dep, aim + delta) // increase aim
        case "forward" => (hor + delta, dep + delta * aim, aim) // move


@main def day2Part2() =
    val data = loadData()
    // starting from position (0,0,0), update the position with all the instructions
    val finalPos = data.foldLeft((0, 0, 0))((pos, instr) => updatePosition(pos, instr))
    val result = finalPos(0) * finalPos(1)
    printf("Part 2: %d\n", result)
